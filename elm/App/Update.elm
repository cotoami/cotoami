module App.Update exposing (..)

import Dict
import Task
import Process
import Time
import Http exposing (Error(..))
import Keys exposing (ctrl, meta, enter)
import Navigation 
import App.Types exposing (..)
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
import Components.Connections.Model exposing (addRootConnection)


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
            { model | session = Just session } ! []
            
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
            
        StockToggle ->
            { model 
            | stockToggled = True
            , stockOpen = (not model.stockOpen) 
            } ! []
            
        HomeClick ->
            changeLocationToHome model
            
        CotonomaFetched (Ok (cotonoma, members, posts)) ->
            let
                ( timeline, cmd ) = 
                    Components.Timeline.Update.update 
                      model.clientId
                      model.cotonoma
                      model.ctrlDown
                      (Components.Timeline.Messages.PostsFetched (Ok posts))
                      model.timeline
            in
                { model 
                | cotonoma = Just cotonoma
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
                { model | ctrlDown = True } ! []
            else
                model ! []

        KeyUp key ->
            if key == ctrl.keyCode || key == meta.keyCode then
                { model | ctrlDown = False } ! []
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
                confirmModal = model.confirmModal
                timeline = model.timeline
                posts = timeline.posts
            in
                case subMsg of
                    Components.CotoModal.ConfirmDelete message ->
                        { model 
                        | cotoModal = cotoModal
                        , confirmModal =
                            { confirmModal
                            | open = True
                            , message = message
                            , msgOnConfirm = 
                                (case cotoModal.coto of
                                    Nothing -> App.Messages.NoOp
                                    Just coto -> CotoModalMsg (Components.CotoModal.Delete coto)
                                )
                            }
                        } ! [ Cmd.map CotoModalMsg cmd ]
                        
                    Components.CotoModal.Delete coto  -> 
                        { model 
                        | cotoModal = cotoModal
                        , timeline =
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
                        { model | cotoModal = cotoModal } ! [ Cmd.map CotoModalMsg cmd ]
            
        TimelineMsg subMsg ->
            let
                ( timeline, cmd ) = 
                    Components.Timeline.Update.update 
                        model.clientId
                        model.cotonoma
                        model.ctrlDown
                        subMsg 
                        model.timeline
                cotoModal = model.cotoModal
            in
                case subMsg of
                    Components.Timeline.Messages.PostClick cotoId ->
                        { model 
                        | timeline = timeline
                        , connectMode = updateConnectMode cotoId model.connectMode
                        } ! [ Cmd.map TimelineMsg cmd ]
                        
                    Components.Timeline.Messages.PostOpen post ->
                        { model 
                        | timeline = timeline
                        , cotoModal = 
                            { cotoModal 
                            | open = True
                            , coto = toCoto post
                            }
                        } ! [ Cmd.map TimelineMsg cmd ]
                        
                    Components.Timeline.Messages.CotonomaClick key ->
                        changeLocationToCotonoma key model
                        
                    Components.Timeline.Messages.CotonomaPushed post ->
                        { model | timeline = timeline } ! 
                            [ Cmd.map TimelineMsg cmd
                            , fetchRecentCotonomas
                            , fetchSubCotonomas model.cotonoma
                            ]

                    _ -> 
                        { model | timeline = timeline } ! [ Cmd.map TimelineMsg cmd ]
  
        DeleteCoto coto ->
            let
                timeline = model.timeline
                posts = timeline.posts
            in
                { model 
                | timeline =
                    { timeline
                    | posts = posts |> 
                        List.filter (\post -> not (isSelfOrPostedIn coto post))
                    }
                } ! 
                    (if coto.asCotonoma then 
                        [ fetchRecentCotonomas 
                        , fetchSubCotonomas model.cotonoma 
                        ] 
                     else []) 
                
        CotoDeleted _ ->
            model ! []
            
        OpenCotonomaModal ->
            let
                cotonomaModal = 
                    case model.session of
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
            case model.session of
                Nothing -> model ! []
                Just session -> 
                    let
                        ( cotonomaModal, timeline, cmd ) = 
                            Components.CotonomaModal.Update.update
                                model.clientId
                                session
                                model.cotonoma
                                subMsg
                                model.timeline
                                model.cotonomaModal
                        newModel = 
                            { model | cotonomaModal = cotonomaModal, timeline = timeline }
                        commands = [ Cmd.map CotonomaModalMsg cmd ]
                    in
                        case subMsg of
                            Components.CotonomaModal.Messages.Posted (Ok _) ->
                                { newModel | cotonomasLoading = True } 
                                    ! List.append
                                        [ fetchRecentCotonomas
                                        , fetchSubCotonomas model.cotonoma
                                        ]
                                        commands
                            _ -> 
                                newModel ! commands
                                
        CotonomaClick key ->
            changeLocationToCotonoma key model
            
        CotonomaPresenceState payload ->
            { model | memberPresences = decodePresenceState payload } ! []
            
        CotonomaPresenceDiff payload ->
            let
                presenceDiff = decodePresenceDiff payload
                newMemberPresences =
                    applyPresenceDiff presenceDiff model.memberPresences
            in
                { model | memberPresences = newMemberPresences } ! []
                
        ConnectionsMsg subMsg ->
            model ! []
            
        Stock ->
            case model.connectMode of
                Nothing -> model ! []
                Just connectMode -> stock connectMode model ! []
                
        OpenConnectModal ->
            { model | connectModalOpen = True } ! []
            
        CloseConnectModal ->
            { model | connectModalOpen = False } ! []


stock : ConnectMode -> Model -> Model
stock connectMode model =
    let
        newConnections =
            case getCoto connectMode.baseCotoId model of
                Nothing -> model.connections
                Just coto -> addRootConnection coto model.connections
    in
        { model 
        | connections = newConnections
        , connectMode = Nothing 
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
    | cotonoma = Nothing
    , members = []
    , cotonomasLoading = True
    , subCotonomas = []
    , timeline = setLoading model.timeline 
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
    | cotonoma = Nothing
    , members = []
    , cotonomasLoading = True
    , timeline = setLoading model.timeline 
    } ! 
        [ fetchRecentCotonomas
        , fetchCotonoma key 
        ]


updateConnectMode : Int -> Maybe ConnectMode -> Maybe ConnectMode
updateConnectMode clickedId maybeConnectMode =
    case maybeConnectMode of
        Nothing -> Just (ConnectMode clickedId [])
        Just connectMode -> 
            if clickedId == connectMode.baseCotoId then
                Nothing
            else
                let
                    targetCotoIds = connectMode.targetCotoIds
                    newTargetCotoIds =
                        if List.member clickedId targetCotoIds then
                            List.filter (\id -> clickedId /= id) targetCotoIds
                        else
                            clickedId :: targetCotoIds
                in
                    Just { connectMode | targetCotoIds = newTargetCotoIds }
            
