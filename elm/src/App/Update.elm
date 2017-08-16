module App.Update exposing (..)

import Dict
import Task
import Process
import Time
import Json.Decode as Decode
import Http exposing (Error(..))
import Keys exposing (ctrl, meta, enter, escape)
import Navigation
import Utils exposing (isBlank, send)
import App.ActiveViewOnMobile exposing (ActiveViewOnMobile(..))
import App.Types.Context exposing (..)
import App.Types.Coto exposing (Coto, CotoId, CotonomaKey)
import App.Types.Post exposing (Post, toCoto, isPostedInCoto, isSelfOrPostedIn, setCotoSaved)
import App.Types.MemberPresences exposing (MemberPresences)
import App.Types.Graph exposing (..)
import App.Types.Post exposing (Post, defaultPost)
import App.Types.Timeline exposing (setEditingNew, updatePost, setLoading, postContent)
import App.Model exposing (..)
import App.Messages exposing (..)
import App.Route exposing (parseLocation, Route(..))
import App.Server.Cotonoma exposing (fetchRecentCotonomas, fetchSubCotonomas)
import App.Server.Coto exposing (fetchPosts, fetchCotonomaPosts, deleteCoto, decodePost)
import App.Server.Graph exposing (fetchGraph, fetchSubgraphIfCotonoma, unpinCoto, disconnect)
import App.Commands exposing (scrollToBottom)
import App.Channels exposing (Payload, decodePayload, decodePresenceState, decodePresenceDiff)
import Components.ConfirmModal.Update
import Components.SigninModal
import Components.ProfileModal
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
            | context =
                model.context
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

        SwitchViewOnMobile view ->
            { model
            | activeViewOnMobile = view
            } ! []

        HomeClick ->
            changeLocationToHome model

        CotonomaFetched (Ok (cotonoma, members, posts)) ->
            { model
            | context = model.context
                |> \context -> { context | cotonoma = Just cotonoma }
            , members = members
            , navigationOpen = False
            , timeline = model.timeline
                |> \t -> { t | posts = posts, loading = False }
            } !
                [ scrollToBottom NoOp
                , fetchSubCotonomas (Just cotonoma)
                ]


        CotonomaFetched (Err _) ->
            model ! []

        GraphFetched (Ok graph) ->
            { model | graph = graph } ! []

        GraphFetched (Err _) ->
            model ! []

        SubgraphFetched (Ok subgraph) ->
            { model | graph = mergeSubgraph subgraph model.graph } ! []

        SubgraphFetched (Err _) ->
            model ! []

        KeyDown key ->
            if key == ctrl.keyCode || key == meta.keyCode then
                { model | context = ctrlDown True model.context } ! []
            else if key == escape.keyCode then
                (closeModal model) ! []
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

        PostsFetched (Ok posts) ->
            { model
            | timeline = model.timeline |> \t -> { t | posts = posts , loading = False }
            } ! [ scrollToBottom NoOp ]

        PostsFetched (Err _) ->
            model ! []

        ImageLoaded ->
            model ! [ scrollToBottom NoOp ]

        EditorFocus ->
            { model | timeline = setEditingNew True model.timeline } ! []

        EditorBlur ->
            { model | timeline = setEditingNew False model.timeline } ! []

        EditorInput content ->
            { model | timeline = model.timeline |> \t -> { t | newContent = content } } ! []

        EditorKeyDown key ->
            if key == enter.keyCode && model.context.ctrlDown && (not (isBlank model.timeline.newContent)) then
                post model
            else
                model ! []

        Post ->
            post model

        Posted (Ok response) ->
            { model
            | timeline = model.timeline |> \t -> { t | posts = setCotoSaved response t.posts }
            } ! []

        Posted (Err _) ->
            model ! []

        OpenPost post ->
            openCoto (toCoto post) model ! []

        PostPushed payload ->
            case Decode.decodeValue (decodePayload "post" decodePost) payload of
                Ok decodedPayload ->
                    handlePushedPost model.context.clientId decodedPayload model
                Err err ->
                    model ! []

        CotonomaPushed post ->
            model !
                [ fetchRecentCotonomas
                , fetchSubCotonomas model.context.cotonoma
                ]

        DeleteCoto coto ->
            { model
            | timeline = App.Types.Timeline.deleteCoto coto model.timeline
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
                                Components.CotonomaModal.Messages.Posted (Ok response) ->
                                    { model
                                    | cotonomasLoading = True
                                    , timeline =
                                        model.timeline
                                            |> \t -> { t | posts = setCotoSaved response t.posts }
                                    } !
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
            openTraversal Components.Traversals.Model.Opened cotoId model !
                [ fetchSubgraphIfCotonoma model.graph cotoId ]

        CotonomaClick key ->
            changeLocationToCotonoma key model

        ConfirmUnpinCoto cotoId ->
            confirm
                "Are you sure you want to unpin this coto?"
                (UnpinCoto cotoId)
                model
            ! []

        UnpinCoto cotoId ->
            { model | graph = model.graph |> deleteRootConnection cotoId } !
                [ unpinCoto
                    CotoUnpinned
                    (Maybe.map (\cotonoma -> cotonoma.key) model.context.cotonoma)
                    cotoId
                ]

        CotoUnpinned (Ok _) ->
            model ! []

        CotoUnpinned (Err _) ->
            model ! []

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
                            openTraversal Components.Traversals.Model.Opened cotoId model !
                                [ cmd, fetchSubgraphIfCotonoma model.graph cotoId ]

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
            connect startCoto endCotos model !
                [ App.Server.Graph.connect
                    Connected
                    (Maybe.map (\cotonoma -> cotonoma.key) model.context.cotonoma)
                    startCoto.id
                    (List.map (\coto -> coto.id) endCotos)
                ]

        Connected (Ok _) ->
            model ! []

        Connected (Err _) ->
            model ! []

        TraversalMsg subMsg ->
            Components.Traversals.Update.update subMsg model.traversals
                |> \( traversals, cmd ) ->
                    { model | traversals = traversals } ! [ Cmd.map TraversalMsg cmd ]
                |> \( model, cmd ) ->
                    case subMsg of
                        Components.Traversals.Messages.CotoClick cotoId ->
                            clickCoto cotoId model ! [ cmd ]

                        Components.Traversals.Messages.CotoMouseEnter cotoId ->
                            { model | context = setFocus (Just cotoId) model.context } ! [ cmd ]

                        Components.Traversals.Messages.CotoMouseLeave cotoId ->
                            { model | context = setFocus Nothing model.context } ! [ cmd ]

                        Components.Traversals.Messages.OpenCoto coto ->
                            openCoto (Just coto) model ! [ cmd ]

                        Components.Traversals.Messages.SelectCoto cotoId ->
                            { model | context = updateSelection cotoId model.context } ! [ cmd ]

                        Components.Traversals.Messages.CotonomaClick key ->
                            changeLocationToCotonoma key model

                        Components.Traversals.Messages.OpenTraversal cotoId ->
                            openTraversal Components.Traversals.Model.Opened cotoId model !
                                [ cmd, fetchSubgraphIfCotonoma model.graph cotoId ]

                        Components.Traversals.Messages.ConfirmDeleteConnection conn ->
                            confirm
                                ("Are you sure you want to delete this connection?")
                                (TraversalMsg (Components.Traversals.Messages.DeleteConnection conn))
                                model
                            ! [ cmd ]

                        Components.Traversals.Messages.DeleteConnection (startId, endId) ->
                            { model
                            | graph = deleteConnection (startId, endId) model.graph
                            } !
                                [ cmd
                                , disconnect
                                    ConnectionDeleted
                                    (Maybe.map (\cotonoma -> cotonoma.key) model.context.cotonoma)
                                    startId
                                    endId
                                ]

                        _ ->
                            ( model, cmd )

        ConnectionDeleted (Ok _) ->
            model ! []

        ConnectionDeleted (Err _) ->
            model ! []


confirm : String -> Msg -> Model -> Model
confirm message msgOnConfirm model =
    { model
    | confirmModal = model.confirmModal
        |> \modal ->
            { modal
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
    { model
    | cotoModal = model.cotoModal
        |> \modal -> { modal | open = True , coto =  maybeCoto }
    }


applyPresenceDiff : ( MemberPresences, MemberPresences ) -> MemberPresences -> MemberPresences
applyPresenceDiff ( joins, leaves ) presences =
    -- Join
    (Dict.foldl
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
        joins
    )
        |> \presences ->
            -- Leave
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
                presences
                leaves


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
    , graph = defaultGraph
    , traversals = Components.Traversals.Model.initModel
    , activeViewOnMobile = TimelineView
    } !
        [ fetchPosts
        , fetchRecentCotonomas
        , fetchGraph Nothing
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
    , graph = defaultGraph
    , traversals = Components.Traversals.Model.initModel
    , activeViewOnMobile = TimelineView
    } !
        [ fetchRecentCotonomas
        , fetchCotonomaPosts key
        , fetchGraph (Just key)
        ]


closeOpenable : { a | open : Bool } -> { a | open : Bool }
closeOpenable openable =
    { openable | open = False }


closeModal : Model -> Model
closeModal model =
    if model.confirmModal.open then
       { model | confirmModal = model.confirmModal |> closeOpenable }
    else if model.signinModal.open && not model.signinModal.requestDone then
       { model | signinModal = model.signinModal |> closeOpenable }
    else if model.profileModal.open then
       { model | profileModal = model.profileModal |> closeOpenable }
    else if model.cotoModal.open then
       { model | cotoModal = model.cotoModal |> closeOpenable }
    else if model.cotonomaModal.open then
       { model | cotonomaModal = model.cotonomaModal |> closeOpenable }
    else if model.connectMode then
       { model | connectModalOpen = False, connectMode = False }
    else
        model


handlePushedPost : String -> Payload Post -> Model -> ( Model, Cmd Msg )
handlePushedPost clientId payload model =
    if payload.clientId /= clientId then
        { model
        | timeline =
            model.timeline
                |> \t -> { t | posts = payload.body :: t.posts }
        } !
            if payload.body.asCotonoma then
                [ scrollToBottom NoOp, send (CotonomaPushed payload.body) ]
            else
                [ scrollToBottom NoOp ]
    else
        model ! []


post : Model -> ( Model, Cmd Msg )
post model =
    let
        clientId = model.context.clientId
        cotonoma = model.context.cotonoma
        newContent = model.timeline.newContent
    in
        model.timeline
            |> postContent clientId cotonoma False newContent
            |> \( timeline, newPost ) ->
                { model | timeline = timeline } !
                    [ scrollToBottom NoOp
                    , App.Server.Coto.post clientId cotonoma Posted newPost
                    ]
