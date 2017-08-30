module App.Update exposing (..)

import Set
import Dict
import Task
import Process
import Time
import Maybe exposing (andThen, withDefault)
import Json.Decode as Decode
import Http exposing (Error(..))
import Keys exposing (ctrl, meta, enter, escape)
import Navigation
import Utils exposing (isBlank, send)
import App.ActiveViewOnMobile exposing (ActiveViewOnMobile(..))
import App.Types.Context exposing (..)
import App.Types.Coto exposing (Coto, ElementId, CotoId, CotonomaKey)
import App.Types.Post exposing (Post, toCoto, isPostedInCoto, isSelfOrPostedIn)
import App.Types.MemberPresences exposing (MemberPresences)
import App.Types.Graph exposing (..)
import App.Types.Post exposing (Post, defaultPost)
import App.Types.Timeline exposing (setEditingNew, updatePost, setLoading, postContent, setCotoSaved)
import App.Types.Traversal exposing (closeTraversal, defaultTraversals, updateTraversal, doTraverse)
import App.Model exposing (..)
import App.Messages exposing (..)
import App.Route exposing (parseLocation, Route(..))
import App.Server.Cotonoma exposing (fetchRecentCotonomas, fetchSubCotonomas)
import App.Server.Coto exposing (fetchPosts, fetchCotonomaPosts, deleteCoto, decodePost)
import App.Server.Graph exposing (fetchGraph, fetchSubgraphIfCotonoma)
import App.Commands exposing (scrollToBottom)
import App.Channels exposing (Payload, decodePayload, decodePresenceState, decodePresenceDiff)
import Components.ConfirmModal.Update
import Components.SigninModal
import Components.ProfileModal
import Components.CotoModal
import Components.CotonomaModal.Model exposing (setDefaultMembers)
import Components.CotonomaModal.Messages
import Components.CotonomaModal.Update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
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

        CotonomaPresenceState payload ->
            { model | memberPresences = decodePresenceState payload } ! []

        CotonomaPresenceDiff payload ->
            decodePresenceDiff payload
                |> \diff -> applyPresenceDiff diff model.memberPresences
                |> \presences -> { model | memberPresences = presences } ! []

        --
        -- Fetched
        --

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

        --
        -- Modal
        --

        OpenSigninModal ->
            openSigninModal model ! []

        OpenProfileModal ->
            model.profileModal
                |> \modal -> { model | profileModal = { modal | open = True } } ! []

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

        CloseConnectModal ->
            { model | connectingCotoId = Nothing } ! []

        --
        -- Coto
        --

        CotoClick elementId cotoId ->
            clickCoto elementId cotoId model ! []

        CotoMouseEnter elementId cotoId ->
            { model
            | context =
                model.context
                    |> setElementFocus (Just elementId)
                    |> setCotoFocus (Just cotoId)
            } ! []

        CotoMouseLeave elementId cotoId ->
            { model
            | context =
                model.context
                    |> setElementFocus Nothing
                    |> setCotoFocus Nothing
            } ! []

        OpenCoto coto ->
            openCoto (Just coto) model ! []

        SelectCoto cotoId ->
            ( { model
              | context = updateSelection cotoId model.context
              } |> closeSelectionColumnIfEmpty
            , Cmd.none
            )

        OpenTraversal cotoId ->
            openTraversal App.Types.Traversal.Opened cotoId model
                |> \model -> model ! [ fetchSubgraphIfCotonoma model.graph cotoId ]

        CotonomaClick key ->
            changeLocationToCotonoma key model

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

        PinCoto cotoId ->
            App.Model.getCoto cotoId model
                |> Maybe.map (\coto ->
                    { model
                    | graph = pinCoto coto model.graph
                    } !
                        [ App.Server.Graph.pinCotos
                            (Maybe.map (\cotonoma -> cotonoma.key) model.context.cotonoma)
                            [ cotoId ]
                        ]
                )
                |> withDefault (model ! [])

        CotoPinned (Ok _) ->
            model ! []

        CotoPinned (Err _) ->
            model ! []

        ConfirmUnpinCoto cotoId ->
            confirm
                "Are you sure you want to unpin this coto?"
                (UnpinCoto cotoId)
                model
            ! []

        UnpinCoto cotoId ->
            { model | graph = model.graph |> unpinCoto cotoId } !
                [ App.Server.Graph.unpinCoto
                    (Maybe.map (\cotonoma -> cotonoma.key) model.context.cotonoma)
                    cotoId
                ]

        CotoUnpinned (Ok _) ->
            model ! []

        CotoUnpinned (Err _) ->
            model ! []

        ConfirmConnect cotoId direction ->
            { model
            | connectingCotoId = Just cotoId
            , connectingDirection = direction
            } ! []

        Connect subject objects direction ->
            App.Model.connect direction subject objects model !
                [ App.Server.Graph.connect
                    (Maybe.map (\cotonoma -> cotonoma.key) model.context.cotonoma)
                    direction
                    (List.map (\coto -> coto.id) objects)
                    subject.id
                ]

        Connected (Ok _) ->
            model ! []

        Connected (Err _) ->
            model ! []

        ConfirmDeleteConnection conn ->
            confirm
                ("Are you sure you want to delete this connection?")
                (DeleteConnection conn)
                model
            ! []

        DeleteConnection ( startId, endId ) ->
            { model
            | graph = disconnect ( startId, endId ) model.graph
            } !
                [ App.Server.Graph.disconnect
                    (Maybe.map (\cotonoma -> cotonoma.key) model.context.cotonoma)
                    startId
                    endId
                ]

        ConnectionDeleted (Ok _) ->
            model ! []

        ConnectionDeleted (Err _) ->
            model ! []

        --
        -- Timeline
        --

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
                post Nothing model
            else
                model ! []

        Post maybeDirection ->
            post maybeDirection model

        Posted (Ok response) ->
            { model | timeline = setCotoSaved response model.timeline } ! []

        Posted (Err _) ->
            model ! []

        PostedAndConnect (Ok post) ->
            model ! []

        PostedAndConnect (Err _) ->
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

        --
        -- Traversals
        --

        TraverseClick traverse ->
            { model
            | traversals = updateTraversal (doTraverse traverse) model.traversals
            } ! []

        CloseTraversal cotoId ->
            { model
            | traversals = closeTraversal cotoId model.traversals
            } ! []

        SwitchTraversal pageIndex ->
            { model
            | traversals = model.traversals |> \t -> { t | activeIndexOnMobile = pageIndex }
            } ! []

        --
        -- CotoSelection
        --

        DeselectingCoto cotoId ->
            { model | context = setBeingDeselected cotoId model.context } !
                [ Process.sleep (1 * Time.second)
                  |> Task.andThen (\_ -> Task.succeed ())
                  |> Task.perform (\_ -> DeselectCoto)
                ]

        DeselectCoto ->
            doDeselect model ! []

        ClearSelection ->
            { model
            | context = clearSelection model.context
            , connectingCotoId = Nothing
            , cotoSelectionColumnOpen = False
            , activeViewOnMobile =
                case model.activeViewOnMobile of
                    SelectionView -> TimelineView
                    anotherView -> anotherView
            } ! []

        CotoSelectionColumnToggle ->
            { model
            | cotoSelectionColumnOpen = (not model.cotoSelectionColumnOpen)
            } ! []

        CotoSelectionTitleInput title ->
            { model | cotoSelectionTitle = title } ! []

        ConfirmCreateGroupingCoto ->
            confirm
                ("You are about to create a grouping coto: \"" ++ model.cotoSelectionTitle ++ "\"")
                PostGroupingCoto
                model
            ! []

        PostGroupingCoto ->
            model.timeline
                |> postContent
                    model.context.clientId
                    model.context.cotonoma
                    False
                    model.cotoSelectionTitle
                |> \( timeline, newPost ) ->
                    { model
                    | timeline = timeline
                    , cotoSelectionTitle = ""
                    } !
                        [ scrollToBottom NoOp
                        , App.Server.Coto.post
                            model.context.clientId
                            model.context.cotonoma
                            GroupingCotoPosted
                            newPost
                        ]

        GroupingCotoPosted (Ok response) ->
            { model
            | timeline = setCotoSaved response model.timeline
            }
                |> (\model ->
                    response.cotoId
                        |> andThen (\cotoId -> App.Model.getCoto cotoId model)
                        |> Maybe.map (\startCoto ->
                            let
                                endCotos = getSelectedCotos model
                            in
                                ( App.Model.connect Outbound startCoto endCotos model
                                , App.Server.Graph.connect
                                    (Maybe.map (\cotonoma -> cotonoma.key) model.context.cotonoma)
                                    Outbound
                                    (List.map (\coto -> coto.id) endCotos)
                                    startCoto.id
                                )
                        )
                        |> withDefault (model ! [])
                )

        GroupingCotoPosted (Err _) ->
            model ! []

        --
        -- Sub components
        --

        ConfirmModalMsg subMsg ->
            Components.ConfirmModal.Update.update subMsg model.confirmModal
                |> \( modal, cmd ) -> { model | confirmModal = modal } ! [ cmd ]

        SigninModalMsg subMsg ->
            Components.SigninModal.update subMsg model.signinModal
                |> \( modal, cmd ) ->
                    { model | signinModal = modal } ! [ Cmd.map SigninModalMsg cmd ]

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
                                    , timeline = setCotoSaved response model.timeline
                                    } !
                                        [ cmd
                                        , fetchRecentCotonomas
                                        , fetchSubCotonomas model.context.cotonoma
                                        ]
                                _ ->
                                    ( model, cmd )


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

clickCoto : ElementId -> CotoId -> Model -> Model
clickCoto elementId cotoId model =
    { model
    | context =
        model.context
            |> setElementFocus (Just elementId)
            |> setCotoFocus (Just cotoId)
    }


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
    , connectingCotoId = Nothing
    , graph = defaultGraph
    , traversals = defaultTraversals
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
    , connectingCotoId = Nothing
    , graph = defaultGraph
    , traversals = defaultTraversals
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


post : Maybe Direction -> Model -> ( Model, Cmd Msg )
post maybeDirection model =
    let
        clientId = model.context.clientId
        cotonoma = model.context.cotonoma
        newContent = model.timeline.newContent
        postMsg =
            case maybeDirection of
                Nothing -> Posted
                Just _ -> PostedAndConnect
    in
        model.timeline
            |> postContent clientId cotonoma False newContent
            |> \( timeline, newPost ) ->
                { model
                | timeline = timeline
                , connectingDirection =
                    Maybe.withDefault Outbound maybeDirection
                } !
                    [ scrollToBottom NoOp
                    , App.Server.Coto.post clientId cotonoma postMsg newPost
                    ]


pinSelectedCotos : Model -> Model
pinSelectedCotos model =
    model.context.selection
        |> List.filterMap (\cotoId -> App.Model.getCoto cotoId model)
        |> \cotos -> model.graph |> pinCotos cotos
        |> \graph ->
            { model
            | graph = graph
            , context = clearSelection model.context
            , activeViewOnMobile = PinnedView
            }


doDeselect : Model -> Model
doDeselect model =
    { model
    | context = model.context
        |> \context ->
            { context
            | selection =
                List.filter
                    (\id -> not(Set.member id context.deselecting))
                    context.selection
            , deselecting = Set.empty
            }
    }
        |> closeSelectionColumnIfEmpty
