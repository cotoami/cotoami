module App.Update exposing (..)

import Dict
import Task
import Process
import Time
import Http exposing (Error(..))
import Keys exposing (ctrl, meta, enter)
import Navigation 
import App.Types exposing (..)
import App.Graph exposing (..)
import App.Model exposing (..)
import App.Messages exposing (..)
import App.Routing exposing (parseLocation)
import App.Commands exposing 
    ( fetchRecentCotonomas
    , fetchSubCotonomas
    , fetchCotonoma
    , deleteCoto
    )
import App.Channels exposing (decodePresenceState, decodePresenceDiff)
import Components.ConfirmModal.Update
import Components.SigninModal
import Components.ProfileModal
import Components.Timeline.Model 
    exposing (updatePost, toCoto, isPostedInCoto, isSelfOrPostedIn, setLoading)
import Components.Timeline.Messages
import Components.Timeline.Update
import Components.Timeline.Commands exposing (fetchPosts)
import Components.CotoModal
import Components.CotonomaModal.Model exposing (setDefaultMembers)
import Components.CotonomaModal.Messages
import Components.CotonomaModal.Update
import Components.Traversals.Messages
import Components.Traversals.Model exposing (closeTraversal)
import Components.Traversals.Update
import Components.CotoSelection.Messages
import Components.CotoSelection.Update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            model ! []
            
        OnLocationChange location ->
            let
                newRoute = parseLocation location
                newModel = { model | route = newRoute }
            in
                case newRoute of
                    HomeRoute ->
                        loadHome model
                        
                    CotonomaRoute key ->
                        loadCotonoma key newModel
                      
                    NotFoundRoute ->
                        ( newModel, Cmd.none )
                
            
        SessionFetched (Ok session) ->
            let
                context = model.context
            in
                { model 
                | context = { context | session = Just session } 
                } ! []
            
        SessionFetched (Err error) ->
            case error of
                BadStatus response ->
                    if response.status.code == 404 then
                        openSigninModal model ! []
                    else
                        model ! []
                _ ->
                    model ! []
            
        RecentCotonomasFetched (Ok cotonomas) ->
            { model 
            | recentCotonomas = cotonomas
            , cotonomasLoading = False 
            } ! []
            
        RecentCotonomasFetched (Err _) ->
            { model | cotonomasLoading = False } ! []
            
        SubCotonomasFetched (Ok cotonomas) ->
            { model | subCotonomas = cotonomas } ! []
            
        SubCotonomasFetched (Err _) ->
            model ! []
            
        NavigationToggle ->
            { model 
            | navigationToggled = True
            , navigationOpen = (not model.navigationOpen) 
            } ! []
            
        SwitchViewInMobile view ->
            { model 
            | viewInMobile = view
            } ! []
                        
        HomeClick ->
            changeLocationToHome model
            
        CotonomaFetched (Ok (cotonoma, members, posts)) ->
            let
                context = model.context
                ( timeline, cmd ) = 
                    Components.Timeline.Update.update 
                      context
                      (Components.Timeline.Messages.PostsFetched (Ok posts))
                      model.timeline
            in
                { model 
                | context = { context | cotonoma = Just cotonoma }
                , members = members
                , navigationOpen = False
                , timeline = timeline
                } ! 
                    [ Cmd.map TimelineMsg cmd
                    , fetchSubCotonomas (Just cotonoma)
                    ]
            
        CotonomaFetched (Err _) ->
            model ! []
        
        KeyDown key ->
            if key == ctrl.keyCode || key == meta.keyCode then
                { model | context = ctrlDown True model.context } ! []
            else
                model ! []

        KeyUp key ->
            if key == ctrl.keyCode || key == meta.keyCode then
                { model | context = ctrlDown False model.context } ! []
            else
                model ! []
                
        ConfirmModalMsg subMsg ->
            let
                ( confirmModal, cmd ) = Components.ConfirmModal.Update.update subMsg model.confirmModal
            in
                { model | confirmModal = confirmModal } ! [ cmd ]
            
        OpenSigninModal ->
            openSigninModal model ! []
            
        SigninModalMsg subMsg ->
            let
                ( signinModal, cmd ) = Components.SigninModal.update subMsg model.signinModal
            in
                { model | signinModal = signinModal } ! [ Cmd.map SigninModalMsg cmd ]
                
        OpenProfileModal ->
            let
                profileModal = model.profileModal
            in
                { model | profileModal = { profileModal | open = True } } ! []
                
        ProfileModalMsg subMsg ->
            let
                ( profileModal, cmd ) = Components.ProfileModal.update subMsg model.profileModal
            in
                { model | profileModal = profileModal } ! [ Cmd.map ProfileModalMsg cmd ]
                
        CotoModalMsg subMsg ->
            let
                ( cotoModal, cmd ) = Components.CotoModal.update subMsg model.cotoModal
                newModel = { model | cotoModal = cotoModal }
                confirmModal = newModel.confirmModal
                timeline = newModel.timeline
                posts = timeline.posts
            in
                case subMsg of
                    Components.CotoModal.ConfirmDelete ->
                        confirm 
                            "Are you sure you want to delete this coto?" 
                            (case cotoModal.coto of
                                Nothing -> App.Messages.NoOp
                                Just coto -> CotoModalMsg (Components.CotoModal.Delete coto)
                            ) 
                            newModel
                        ! [ Cmd.map CotoModalMsg cmd ]
                        
                    Components.CotoModal.Delete coto  -> 
                        { newModel 
                        | timeline =
                            { timeline
                            | posts = posts |> List.map 
                                (\post -> 
                                    if isSelfOrPostedIn coto post then
                                        { post | beingDeleted = True }
                                    else
                                        post
                                )
                            }
                        } !
                            [ Cmd.map CotoModalMsg cmd
                            , deleteCoto coto.id
                            , Process.sleep (1 * Time.second)
                              |> Task.andThen (\_ -> Task.succeed ())
                              |> Task.perform (\_ -> DeleteCoto coto)
                            ]
                        
                    _ ->
                        newModel ! [ Cmd.map CotoModalMsg cmd ]
            
        TimelineMsg subMsg ->
            let
                ( timeline, cmd ) = 
                    Components.Timeline.Update.update model.context subMsg model.timeline
                newModel = { model | timeline = timeline }
                cotoModal = newModel.cotoModal
            in
                case subMsg of
                    Components.Timeline.Messages.PostClick cotoId ->
                        (clickCoto cotoId newModel) ! [ Cmd.map TimelineMsg cmd ]
                        
                    Components.Timeline.Messages.PostMouseEnter cotoId ->
                        { newModel | context = setFocus (Just cotoId) newModel.context } 
                            ! [ Cmd.map TimelineMsg cmd ]
                            
                    Components.Timeline.Messages.PostMouseLeave cotoId ->
                        { newModel | context = setFocus Nothing newModel.context } 
                            ! [ Cmd.map TimelineMsg cmd ]
                        
                    Components.Timeline.Messages.OpenPost post ->
                        openCoto (toCoto post) model ! [ Cmd.map TimelineMsg cmd ]
                        
                    Components.Timeline.Messages.CotonomaClick key ->
                        changeLocationToCotonoma key newModel
                        
                    Components.Timeline.Messages.CotonomaPushed post ->
                        newModel ! 
                            [ Cmd.map TimelineMsg cmd
                            , fetchRecentCotonomas
                            , fetchSubCotonomas model.context.cotonoma
                            ]
                            
                    Components.Timeline.Messages.SelectCoto cotoId ->
                        { newModel
                        | context = updateSelection cotoId newModel.context
                        } ! [ Cmd.map TimelineMsg cmd ]
                            
                    Components.Timeline.Messages.OpenTraversal cotoId ->
                        openTraversal Components.Traversals.Model.Opened cotoId model 
                            ! [ Cmd.map TimelineMsg cmd ]

                    _ -> 
                        newModel ! [ Cmd.map TimelineMsg cmd ]
  
        DeleteCoto coto ->
            let
                timeline = model.timeline
                posts = timeline.posts
                ( graph, _ ) = removeCoto coto.id model.graph
            in
                { model 
                | timeline = Components.Timeline.Model.deleteCoto coto model.timeline
                , graph = graph
                , traversals = closeTraversal coto.id model.traversals
                , context = deleteSelection coto.id model.context
                } ! 
                    (if coto.asCotonoma then 
                        [ fetchRecentCotonomas 
                        , fetchSubCotonomas model.context.cotonoma 
                        ] 
                     else []) 
                
        CotoDeleted _ ->
            model ! []
            
        OpenCotonomaModal ->
            let
                cotonomaModal = 
                    case model.context.session of
                        Nothing -> 
                            model.cotonomaModal
                        Just session -> 
                            setDefaultMembers 
                                session 
                                (getOwnerAndMembers model) 
                                model.cotonomaModal
            in
                { model | cotonomaModal = { cotonomaModal | open = True } } ! []
                
        CotonomaModalMsg subMsg ->
            case model.context.session of
                Nothing -> model ! []
                Just session -> 
                    let
                        ( cotonomaModal, timeline, cmd ) = 
                            Components.CotonomaModal.Update.update
                                subMsg
                                session
                                model.context
                                model.timeline
                                model.cotonomaModal
                        newModel = 
                            { model 
                            | cotonomaModal = cotonomaModal
                            , timeline = timeline 
                            }
                        commands = [ Cmd.map CotonomaModalMsg cmd ]
                    in
                        case subMsg of
                            Components.CotonomaModal.Messages.Posted (Ok _) ->
                                { newModel | cotonomasLoading = True } 
                                    ! List.append
                                        [ fetchRecentCotonomas
                                        , fetchSubCotonomas model.context.cotonoma
                                        ]
                                        commands
                            _ -> 
                                newModel ! commands
        
        CotoClick cotoId ->
            clickCoto cotoId model ! []
            
        CotoMouseEnter cotoId ->
            { model | context = setFocus (Just cotoId) model.context } ! []
            
        CotoMouseLeave cotoId ->
            { model | context = setFocus Nothing model.context } ! []
            
        OpenCoto coto ->
            openCoto (Just coto) model ! []
            
        SelectCoto cotoId ->
            { model
            | context = updateSelection cotoId model.context
            } ! []
            
        OpenTraversal cotoId ->
            openTraversal Components.Traversals.Model.Opened cotoId model ! []
                
        CotonomaClick key ->
            changeLocationToCotonoma key model
            
        ConfirmUnpinCoto cotoId ->
            confirm 
                "Are you sure you want to unpin this coto?" 
                (UnpinCoto cotoId)
                model
            ! []
            
        UnpinCoto cotoId ->
            { model | graph = model.graph |> deleteRootConnection cotoId } ! []
            
        CotonomaPresenceState payload ->
            { model | memberPresences = decodePresenceState payload } ! []
            
        CotonomaPresenceDiff payload ->
            let
                presenceDiff = decodePresenceDiff payload
                newMemberPresences =
                    applyPresenceDiff presenceDiff model.memberPresences
            in
                { model | memberPresences = newMemberPresences } ! []
                
        CotoSelectionMsg subMsg ->
            let
                ( newModel, cmd ) = 
                    Components.CotoSelection.Update.update subMsg model
            in
                case subMsg of
                    Components.CotoSelection.Messages.CotonomaClick key ->
                        changeLocationToCotonoma key newModel
                        
                    Components.CotoSelection.Messages.OpenTraversal cotoId ->
                        openTraversal Components.Traversals.Model.Opened cotoId model 
                            ! [ Cmd.map CotoSelectionMsg cmd ]
                        
                    Components.CotoSelection.Messages.ConfirmPin ->
                        confirm 
                            "Are you sure you want to pin the selected cotos?" 
                            (CotoSelectionMsg Components.CotoSelection.Messages.Pin)
                            newModel
                        ! [ Cmd.map CotoSelectionMsg cmd ]
                        
                    Components.CotoSelection.Messages.ConfirmCreateGroupingCoto ->
                        confirm 
                            ("You are about to create a grouping coto: \"" ++ newModel.cotoSelectionTitle ++ "\"")
                            (CotoSelectionMsg Components.CotoSelection.Messages.PostGroupingCoto)
                            newModel
                        ! [ Cmd.map CotoSelectionMsg cmd ]
                        
                    _ -> 
                        newModel ! [ Cmd.map CotoSelectionMsg cmd ]
            
        CloseConnectModal ->
            { model | connectModalOpen = False } ! []
            
        Connect startCoto endCotos ->
            connect startCoto endCotos model ! []
                                
        TraversalMsg subMsg ->
            let
                ( traversals, cmd ) = 
                    Components.Traversals.Update.update subMsg model.traversals
                newModel = { model | traversals = traversals }
            in
                case subMsg of
                    Components.Traversals.Messages.CotoClick cotoId ->
                        clickCoto cotoId newModel ! [ Cmd.map TraversalMsg cmd ]
                        
                    Components.Traversals.Messages.CotoMouseEnter cotoId ->
                        { newModel | context = setFocus (Just cotoId) newModel.context } 
                            ! [ Cmd.map TraversalMsg cmd ]
                            
                    Components.Traversals.Messages.CotoMouseLeave cotoId ->
                        { newModel | context = setFocus Nothing newModel.context } 
                            ! [ Cmd.map TraversalMsg cmd ]
                        
                    Components.Traversals.Messages.OpenCoto coto ->
                        openCoto (Just coto) model ! [ Cmd.map TraversalMsg cmd ]
                        
                    Components.Traversals.Messages.SelectCoto cotoId ->
                        { newModel
                        | context = updateSelection cotoId newModel.context
                        } ! [ Cmd.map TraversalMsg cmd ]
                        
                    Components.Traversals.Messages.CotonomaClick key ->
                        changeLocationToCotonoma key newModel
                        
                    Components.Traversals.Messages.OpenTraversal cotoId ->
                        openTraversal Components.Traversals.Model.Opened cotoId model 
                            ! [ Cmd.map TraversalMsg cmd ]
                            
                    Components.Traversals.Messages.ConfirmDeleteConnection conn ->
                        confirm 
                            ("Are you sure you want to delete this connection?")
                            (TraversalMsg (Components.Traversals.Messages.DeleteConnection conn))
                            newModel
                        ! [ Cmd.map TraversalMsg cmd ]
                        
                    Components.Traversals.Messages.DeleteConnection conn ->
                        { model
                        | graph = deleteConnection conn model.graph
                        } ! [ Cmd.map TraversalMsg cmd ]
                      
                    _ -> 
                        newModel ! [ Cmd.map TraversalMsg cmd ]
      
      
confirm : String -> Msg -> Model -> Model
confirm message msgOnConfirm model =
    let
        confirmModal = model.confirmModal
    in
        { model 
        | confirmModal =
            { confirmModal
            | open = True
            , message = message
            , msgOnConfirm = msgOnConfirm
            }
        }
        
      
clickCoto : CotoId -> Model -> Model
clickCoto cotoId model =
    if model.connectMode then
        if model.context.selection |> List.member cotoId then
            model
        else
            { model
            | connectModalOpen = True
            , connectingTo = Just cotoId
            }
    else
        { model | context = updateFocus cotoId model.context }


openCoto : Maybe Coto -> Model -> Model
openCoto maybeCoto model =
    let
        cotoModal = model.cotoModal
    in 
        { model 
        | cotoModal = 
            { cotoModal 
            | open = True
            , coto =  maybeCoto
            }
        }
        

applyPresenceDiff : ( MemberConnCounts, MemberConnCounts ) -> MemberConnCounts -> MemberConnCounts
applyPresenceDiff diff presences =
    let
        presencesJoined =
          Dict.foldl
              (\amishiId count presences -> 
                  Dict.update 
                      amishiId 
                      (\maybeValue ->
                          case maybeValue of
                              Nothing -> Just count
                              Just value -> Just (value + count)
                      )
                      presences
              )
              presences
              (Tuple.first diff)
    in
        Dict.foldl
            (\amishiId count presences -> 
                Dict.update 
                    amishiId 
                    (\maybeValue ->
                        case maybeValue of
                            Nothing -> Nothing
                            Just value -> Just (value - count)
                    )
                    presences
            )
            presencesJoined
            (Tuple.second diff)


changeLocationToHome : Model -> ( Model, Cmd Msg )
changeLocationToHome model =
    ( model, Navigation.newUrl "/" )


loadHome : Model -> ( Model, Cmd Msg )
loadHome model =
    { model 
    | context = 
        model.context
        |> clearCotonoma
        |> clearSelection
    , members = []
    , cotonomasLoading = True
    , subCotonomas = []
    , timeline = setLoading model.timeline
    , connectMode = False
    , connectingTo = Nothing
    , graph = initGraph
    , traversals = Components.Traversals.Model.initModel
    , viewInMobile = TimelineView
    } ! 
        [ Cmd.map TimelineMsg fetchPosts
        , fetchRecentCotonomas
        ]
        

changeLocationToCotonoma : CotonomaKey -> Model -> ( Model, Cmd Msg )
changeLocationToCotonoma key model =
    ( model, Navigation.newUrl ("/cotonomas/" ++ key) )


loadCotonoma : CotonomaKey -> Model -> ( Model, Cmd Msg )
loadCotonoma key model =
    { model 
    | context = 
        model.context
        |> clearCotonoma
        |> clearSelection
    , members = []
    , cotonomasLoading = True
    , timeline = setLoading model.timeline
    , connectMode = False
    , connectingTo = Nothing
    , graph = initGraph
    , traversals = Components.Traversals.Model.initModel
    , viewInMobile = TimelineView
    } ! 
        [ fetchRecentCotonomas
        , fetchCotonoma key 
        ]
