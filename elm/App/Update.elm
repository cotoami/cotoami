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
            parseLocation location
                |> \route -> ( route, { model | route = route } )
                |> \( route, model ) ->
                    case route of
                        HomeRoute ->
                            loadHome model

                        CotonomaRoute key ->
                            loadCotonoma key model

                        NotFoundRoute ->
                            ( model, Cmd.none )

        SessionFetched (Ok session) ->
            { model
            | context = model.context
                |> \context -> { context | session = Just session }
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
            (Components.Timeline.Update.update
                model.context
                (Components.Timeline.Messages.PostsFetched (Ok posts))
                model.timeline
            )
                |> \( timeline, cmd ) ->
                    { model
                    | context = model.context
                        |> \context -> { context | cotonoma = Just cotonoma }
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
            Components.ConfirmModal.Update.update subMsg model.confirmModal
                |> \( modal, cmd ) -> { model | confirmModal = modal } ! [ cmd ]

        OpenSigninModal ->
            openSigninModal model ! []

        SigninModalMsg subMsg ->
            Components.SigninModal.update subMsg model.signinModal
                |> \( modal, cmd ) ->
                    { model | signinModal = modal } ! [ Cmd.map SigninModalMsg cmd ]

        OpenProfileModal ->
            model.profileModal
                |> \modal -> { model | profileModal = { modal | open = True } } ! []

        ProfileModalMsg subMsg ->
            Components.ProfileModal.update subMsg model.profileModal
                |> \( modal, cmd ) ->
                    { model | profileModal = modal } ! [ Cmd.map ProfileModalMsg cmd ]

        CotoModalMsg subMsg ->
            Components.CotoModal.update subMsg model.cotoModal
                |> \( modal, cmd ) -> { model | cotoModal = modal } ! [ Cmd.map CotoModalMsg cmd ]
                |> \( model, cmd ) ->
                    case subMsg of
                        Components.CotoModal.ConfirmDelete ->
                            confirm
                                "Are you sure you want to delete this coto?"
                                (case model.cotoModal.coto of
                                    Nothing ->
                                        App.Messages.NoOp
                                    Just coto ->
                                        CotoModalMsg (Components.CotoModal.Delete coto)
                                )
                                model
                            ! [ cmd ]

                        Components.CotoModal.Delete coto  ->
                            { model
                            | timeline = model.timeline
                                |> (\timeline ->
                                    { timeline
                                    | posts = timeline.posts |> List.map
                                        (\post ->
                                            if isSelfOrPostedIn coto post then
                                                { post | beingDeleted = True }
                                            else
                                                post
                                        )
                                    }
                                )
                            } !
                                [ cmd
                                , deleteCoto coto.id
                                , Process.sleep (1 * Time.second)
                                    |> Task.andThen (\_ -> Task.succeed ())
                                    |> Task.perform (\_ -> DeleteCoto coto)
                                ]

                        _ ->
                            ( model, cmd )

        TimelineMsg subMsg ->
            Components.Timeline.Update.update model.context subMsg model.timeline
                |> \( timeline, cmd ) -> { model | timeline = timeline } ! [ Cmd.map TimelineMsg cmd ]
                |> \( model, cmd ) ->
                    case subMsg of
                        Components.Timeline.Messages.PostClick cotoId ->
                            (clickCoto cotoId model) ! [ cmd ]

                        Components.Timeline.Messages.PostMouseEnter cotoId ->
                            { model | context = setFocus (Just cotoId) model.context } ! [ cmd ]

                        Components.Timeline.Messages.PostMouseLeave cotoId ->
                            { model | context = setFocus Nothing model.context } ! [ cmd ]

                        Components.Timeline.Messages.OpenPost post ->
                            openCoto (toCoto post) model ! [ cmd ]

                        Components.Timeline.Messages.CotonomaClick key ->
                            changeLocationToCotonoma key model

                        Components.Timeline.Messages.CotonomaPushed post ->
                            model !
                                [ cmd
                                , fetchRecentCotonomas
                                , fetchSubCotonomas model.context.cotonoma
                                ]

                        Components.Timeline.Messages.SelectCoto cotoId ->
                            { model
                            | context = updateSelection cotoId model.context
                            } ! [ cmd ]

                        Components.Timeline.Messages.OpenTraversal cotoId ->
                            openTraversal Components.Traversals.Model.Opened cotoId model ! [ cmd ]

                        _ ->
                            ( model, cmd )

        DeleteCoto coto ->
            { model
            | timeline = Components.Timeline.Model.deleteCoto coto model.timeline
            , graph = removeCoto coto.id model.graph |> \( graph, _ ) -> graph
            , traversals = closeTraversal coto.id model.traversals
            , context = deleteSelection coto.id model.context
            } !
                (if coto.asCotonoma then
                    [ fetchRecentCotonomas
                    , fetchSubCotonomas model.context.cotonoma
                    ]
                 else []
                )

        CotoDeleted _ ->
            model ! []

        OpenCotonomaModal ->
            (case model.context.session of
                Nothing ->
                    model.cotonomaModal
                Just session ->
                    setDefaultMembers
                        session
                        (getOwnerAndMembers model)
                        model.cotonomaModal
            )
                |> \modal -> { model | cotonomaModal = { modal | open = True } } ! []

        CotonomaModalMsg subMsg ->
            case model.context.session of
                Nothing -> model ! []
                Just session ->
                    (Components.CotonomaModal.Update.update
                        subMsg
                        session
                        model.context
                        model.timeline
                        model.cotonomaModal
                    )
                        |> \( modal, timeline, cmd ) ->
                            { model
                            | cotonomaModal = modal
                            , timeline = timeline
                            } ! [ Cmd.map CotonomaModalMsg cmd ]
                        |> \( model, cmd ) ->
                            case subMsg of
                                Components.CotonomaModal.Messages.Posted (Ok _) ->
                                    { model | cotonomasLoading = True } !
                                        [ cmd
                                        , fetchRecentCotonomas
                                        , fetchSubCotonomas model.context.cotonoma
                                        ]
                                _ ->
                                    ( model, cmd )

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
            decodePresenceDiff payload
                |> \diff -> applyPresenceDiff diff model.memberPresences
                |> \presences -> { model | memberPresences = presences } ! []

        CotoSelectionMsg subMsg ->
            Components.CotoSelection.Update.update subMsg model
                |> \( model, cmd ) -> model ! [ Cmd.map CotoSelectionMsg cmd ]
                |> \( model, cmd ) ->
                    case subMsg of
                        Components.CotoSelection.Messages.CotonomaClick key ->
                            changeLocationToCotonoma key model

                        Components.CotoSelection.Messages.OpenTraversal cotoId ->
                            openTraversal Components.Traversals.Model.Opened cotoId model ! [ cmd ]

                        Components.CotoSelection.Messages.ConfirmPin ->
                            confirm
                                "Are you sure you want to pin the selected cotos?"
                                (CotoSelectionMsg Components.CotoSelection.Messages.Pin)
                                model
                            ! [ cmd ]

                        Components.CotoSelection.Messages.ConfirmCreateGroupingCoto ->
                            confirm
                                ("You are about to create a grouping coto: \"" ++ model.cotoSelectionTitle ++ "\"")
                                (CotoSelectionMsg Components.CotoSelection.Messages.PostGroupingCoto)
                                model
                            ! [ cmd ]

                        _ ->
                            ( model, cmd )

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
        { model | context = setFocus (Just cotoId) model.context }


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
