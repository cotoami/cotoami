module App.Update exposing (..)

import Set
import Task
import Process
import Time
import Maybe exposing (andThen, withDefault)
import Keyboard exposing (KeyCode)
import Json.Decode as Decode
import Http exposing (Error(..))
import Util.Keys exposing (enter, escape, n)
import Navigation
import Util.StringUtil exposing (isNotBlank)
import App.ActiveViewOnMobile exposing (ActiveViewOnMobile(..))
import App.Types.Context exposing (..)
import App.Types.Amishi exposing (Presences, applyPresenceDiff)
import App.Types.Coto exposing (Coto, ElementId, CotoId, CotonomaKey)
import App.Types.Post exposing (Post, toCoto, isPostedInCoto, isSelfOrPostedIn)
import App.Types.Graph exposing (..)
import App.Types.Post exposing (Post, defaultPost)
import App.Types.Timeline
    exposing
        ( updatePost
        , setLoading
        , setCotoSaved
        , setBeingDeleted
        , deletePendingPost
        )
import App.Types.Traversal exposing (closeTraversal, defaultTraversals, updateTraversal, doTraverse)
import App.Model exposing (..)
import App.Messages exposing (..)
import App.Confirmation exposing (Confirmation)
import App.Route exposing (parseLocation, Route(..))
import App.Server.Session exposing (decodeSessionNotFoundBodyString)
import App.Server.Cotonoma exposing (fetchCotonomas, fetchSubCotonomas, pinOrUnpinCotonoma)
import App.Server.Post exposing (fetchPosts, fetchCotonomaPosts, decodePost)
import App.Server.Coto exposing (deleteCoto)
import App.Server.Graph exposing (fetchGraph, fetchSubgraphIfCotonoma)
import App.Commands exposing (sendMsg)
import App.Channels exposing (Payload, decodePayload, decodePresenceState, decodePresenceDiff)
import App.Modals.SigninModal exposing (setSignupEnabled)
import App.Modals.EditorModal
import App.Modals.EditorModalMsg
import App.Modals.InviteModal
import App.Modals.ImportModal


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        KeyDown keyCode ->
            { model | context = App.Types.Context.keyDown keyCode model.context }
                |> (\model ->
                        if keyCode == escape.keyCode then
                            ( closeModal model, Cmd.none )
                        else if (keyCode == n.keyCode) && (List.isEmpty model.modals) then
                            openNewEditor model
                        else
                            ( model, Cmd.none )
                   )

        KeyUp keyCode ->
            ( { model | context = App.Types.Context.keyUp keyCode model.context }
            , Cmd.none
            )

        AppClick ->
            ( { model | timeline = App.Types.Timeline.openOrCloseEditor False model.timeline }
            , Cmd.none
            )

        OnLocationChange location ->
            parseLocation location
                |> (\route -> ( route, { model | route = route } ))
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
            }
                ! []

        SwitchViewOnMobile view ->
            ( { model | activeViewOnMobile = view }
            , Cmd.none
            )

        HomeClick ->
            changeLocationToHome model

        CotonomaPresenceState payload ->
            { model | presences = decodePresenceState payload } ! []

        CotonomaPresenceDiff payload ->
            decodePresenceDiff payload
                |> (\diff -> applyPresenceDiff diff model.presences)
                |> \presences -> { model | presences = presences } ! []

        --
        -- Fetched
        --
        SessionFetched (Ok session) ->
            { model | context = setSession session model.context }
                |> (\model ->
                        case model.route of
                            CotonomaRoute key ->
                                loadCotonoma key model

                            _ ->
                                loadHome model
                   )

        SessionFetched (Err error) ->
            case error of
                BadStatus response ->
                    if response.status.code == 404 then
                        decodeSessionNotFoundBodyString response.body
                            |> (\body -> setSignupEnabled body.signupEnabled model.signinModal)
                            |> (\signinModal -> { model | signinModal = signinModal })
                            |> openModal App.Model.SigninModal
                            |> \model -> model ! []
                    else
                        model ! []

                _ ->
                    model ! []

        CotonomasFetched (Ok ( pinned, recent )) ->
            { model
                | pinnedCotonomas = pinned
                , recentCotonomas = recent
                , cotonomasLoading = False
            }
                ! []

        CotonomasFetched (Err _) ->
            { model | cotonomasLoading = False } ! []

        SubCotonomasFetched (Ok cotonomas) ->
            { model | subCotonomas = cotonomas } ! []

        SubCotonomasFetched (Err _) ->
            model ! []

        CotonomaFetched (Ok ( cotonoma, posts )) ->
            { model
                | context = setCotonoma (Just cotonoma) model.context
                , navigationOpen = False
                , timeline = App.Types.Timeline.setPosts posts model.timeline
            }
                ! [ App.Commands.scrollTimelineToBottom NoOp
                  , fetchSubCotonomas (Just cotonoma)
                  ]

        CotonomaFetched (Err _) ->
            model ! []

        CotonomaStatsFetched (Ok stats) ->
            model.cotoMenuModal
                |> Maybe.map (\modal -> { modal | cotonomaStats = Just stats })
                |> Maybe.map (\modal -> { model | cotoMenuModal = Just modal })
                |> Maybe.withDefault model
                |> \model -> ( model, Cmd.none )

        CotonomaStatsFetched (Err _) ->
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
        CloseModal ->
            ( closeModal model, Cmd.none )

        Confirm ->
            ( closeModal model, sendMsg model.confirmation.msgOnConfirm )

        OpenSigninModal ->
            { model | signinModal = App.Modals.SigninModal.defaultModel }
                |> \model -> ( openModal App.Model.SigninModal model, Cmd.none )

        OpenNewEditorModal ->
            openNewEditor model

        OpenInviteModal ->
            { model | inviteModal = App.Modals.InviteModal.defaultModel }
                |> \model -> ( openModal App.Model.InviteModal model, Cmd.none )

        OpenProfileModal ->
            ( openModal App.Model.ProfileModal model, Cmd.none )

        OpenCotoMenuModal coto ->
            ( openCotoMenuModal coto model
            , coto.cotonomaKey
                |> Maybe.map (\key -> App.Server.Cotonoma.fetchStats key)
                |> Maybe.withDefault Cmd.none
            )

        OpenEditorModal coto ->
            ( { model
                | editorModal =
                    App.Modals.EditorModal.initModel
                        (App.Modals.EditorModal.Edit coto)
              }
                |> openModal EditorModal
            , App.Commands.focus "editor-modal-content-input" NoOp
            )

        OpenCotoModal coto ->
            openCoto coto model

        OpenImportModal ->
            { model | importModal = App.Modals.ImportModal.defaultModel }
                |> \model -> ( openModal App.Model.ImportModal model, Cmd.none )

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
            }
                ! []

        CotoMouseLeave elementId cotoId ->
            { model
                | context =
                    model.context
                        |> setElementFocus Nothing
                        |> setCotoFocus Nothing
            }
                ! []

        SelectCoto cotoId ->
            ( { model
                | context = updateSelection cotoId model.context
              }
                |> closeSelectionColumnIfEmpty
            , Cmd.none
            )

        OpenTraversal cotoId ->
            model
                |> openTraversal cotoId
                |> clearModals
                |> \model ->
                    ( model
                    , Cmd.batch
                        [ App.Commands.scrollGraphExplorationToRight NoOp
                        , fetchSubgraphIfCotonoma model.graph cotoId
                        ]
                    )

        CotonomaClick key ->
            changeLocationToCotonoma key model

        ToggleCotoContent elementId ->
            ( { model | context = toggleContent elementId model.context }
            , Cmd.none
            )

        ConfirmDeleteCoto coto ->
            ( confirm
                (Confirmation
                    "Are you sure you want to delete this coto?"
                    (RequestDeleteCoto coto)
                )
                model
            , Cmd.none
            )

        RequestDeleteCoto coto ->
            ({ model | timeline = setBeingDeleted coto model.timeline }
                |> clearModals
            )
                ! [ deleteCoto coto.id
                  , Process.sleep (1 * Time.second)
                        |> Task.andThen (\_ -> Task.succeed ())
                        |> Task.perform (\_ -> DeleteCoto coto)
                  ]

        DeleteCoto coto ->
            { model
                | timeline = App.Types.Timeline.deleteCoto coto model.timeline
                , graph = removeCoto coto.id model.graph |> \( graph, _ ) -> graph
                , traversals = closeTraversal coto.id model.traversals
                , context = deleteSelection coto.id model.context
            }
                ! (if coto.asCotonoma then
                    [ fetchCotonomas
                    , fetchSubCotonomas model.context.cotonoma
                    ]
                   else
                    []
                  )

        CotoDeleted _ ->
            model ! []

        CotoUpdated (Ok coto) ->
            (model
                |> updateCotoContent coto
                |> updateRecentCotonomasByCoto coto
                |> clearModals
            )
                ! if coto.asCotonoma then
                    [ fetchCotonomas
                    , fetchSubCotonomas model.context.cotonoma
                    ]
                  else
                    []

        CotoUpdated (Err error) ->
            model.editorModal
                |> App.Modals.EditorModal.setCotoSaveError error
                |> (\editorModal -> { model | editorModal = editorModal })
                |> \model -> ( model, Cmd.none )

        ConfirmCotonomatize coto ->
            if String.length coto.content <= App.Types.Coto.cotonomaNameMaxlength then
                ( confirm
                    (Confirmation
                        ("You are about to promote this coto to a Cotonoma "
                            ++ "to discuss with others about: '"
                            ++ coto.content
                            ++ "'"
                        )
                        (Cotonomatize coto.id)
                    )
                    model
                , Cmd.none
                )
            else
                ( { model | editorModal = App.Modals.EditorModal.editToCotonomatize coto }
                    |> openModal EditorModal
                , Cmd.none
                )

        Cotonomatize cotoId ->
            ( model, App.Server.Coto.cotonomatize cotoId )

        Cotonomatized (Ok coto) ->
            ( model
                |> App.Model.cotonomatize coto.id coto.cotonomaKey
                |> clearModals
            , Cmd.batch
                [ fetchCotonomas
                , fetchSubCotonomas model.context.cotonoma
                ]
            )

        Cotonomatized (Err error) ->
            model.cotoMenuModal
                |> Maybe.map (\cotoMenuModal -> App.Modals.EditorModal.Edit cotoMenuModal.coto)
                |> Maybe.map App.Modals.EditorModal.initModel
                |> Maybe.map (App.Modals.EditorModal.setCotoSaveError error)
                |> Maybe.map (\editorModal -> { model | editorModal = editorModal })
                |> Maybe.map (openModal EditorModal)
                |> Maybe.withDefault model
                |> \model -> ( model, Cmd.none )

        PinCoto cotoId ->
            (Maybe.map2
                (\session coto ->
                    { model | graph = pinCoto session coto model.graph }
                        ! [ App.Server.Graph.pinCotos
                                (Maybe.map (\cotonoma -> cotonoma.key) model.context.cotonoma)
                                [ cotoId ]
                          , App.Commands.scrollPinnedCotosToBottom NoOp
                          ]
                )
                model.context.session
                (App.Model.getCoto cotoId model)
            )
                |> withDefault ( model, Cmd.none )

        CotoPinned (Ok _) ->
            ( model, Cmd.none )

        CotoPinned (Err _) ->
            ( model, Cmd.none )

        ConfirmUnpinCoto cotoId ->
            ( confirm
                (Confirmation
                    "Are you sure you want to unpin this coto?"
                    (UnpinCoto cotoId)
                )
                model
            , Cmd.none
            )

        UnpinCoto cotoId ->
            { model | graph = model.graph |> unpinCoto cotoId }
                ! [ App.Server.Graph.unpinCoto
                        (Maybe.map (\cotonoma -> cotonoma.key) model.context.cotonoma)
                        cotoId
                  ]

        CotoUnpinned (Ok _) ->
            ( model, Cmd.none )

        CotoUnpinned (Err _) ->
            ( model, Cmd.none )

        ConfirmConnect cotoId direction ->
            { model
                | connectingSubject =
                    App.Model.getCoto cotoId model
                        |> Maybe.map App.Model.Coto
                , connectingDirection = direction
            }
                |> \model ->
                    ( openModal App.Model.ConnectModal model
                    , App.Commands.focus "connect-modal-primary-button" NoOp
                    )

        ReverseDirection ->
            { model
                | connectingDirection =
                    case model.connectingDirection of
                        Outbound ->
                            Inbound

                        Inbound ->
                            Outbound
            }
                ! []

        Connect subject objects direction ->
            App.Model.connect direction objects subject model
                ! [ App.Server.Graph.connect
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
            ( confirm
                (Confirmation
                    "Are you sure you want to delete this connection?"
                    (DeleteConnection conn)
                )
                model
            , Cmd.none
            )

        DeleteConnection ( startId, endId ) ->
            { model
                | graph = disconnect ( startId, endId ) model.graph
            }
                ! [ App.Server.Graph.disconnect
                        (Maybe.map (\cotonoma -> cotonoma.key) model.context.cotonoma)
                        startId
                        endId
                  ]

        ConnectionDeleted (Ok _) ->
            ( model, Cmd.none )

        ConnectionDeleted (Err _) ->
            ( model, Cmd.none )

        --
        -- Cotonoma
        --
        PinOrUnpinCotonoma cotonomaKey pinOrUnpin ->
            ( model, pinOrUnpinCotonoma pinOrUnpin cotonomaKey )

        CotonomaPinnedOrUnpinned (Ok _) ->
            ( { model | cotonomasLoading = True } |> closeModal
            , fetchCotonomas
            )

        CotonomaPinnedOrUnpinned (Err _) ->
            ( model, Cmd.none )

        --
        -- Timeline
        --
        PostsFetched (Ok posts) ->
            { model
                | context = setCotonoma Nothing model.context
                , timeline = App.Types.Timeline.setPosts posts model.timeline
            }
                ! [ App.Commands.scrollTimelineToBottom NoOp ]

        PostsFetched (Err _) ->
            model ! []

        ImageLoaded ->
            model ! [ App.Commands.scrollTimelineToBottom NoOp ]

        EditorFocus ->
            ( { model | timeline = App.Types.Timeline.openOrCloseEditor True model.timeline }
            , Cmd.none
            )

        EditorInput content ->
            { model | timeline = model.timeline |> \t -> { t | newContent = content } } ! []

        EditorKeyDown keyCode ->
            handleEditorShortcut keyCode Nothing model.timeline.newContent model
                |> \( model, cmd ) ->
                    ( model
                    , Cmd.batch [ cmd, App.Commands.focus "quick-coto-input" NoOp ]
                    )

        Post ->
            post Nothing Nothing model.timeline.newContent model
                |> \( model, cmd ) ->
                    ( model
                    , Cmd.batch [ cmd, App.Commands.focus "quick-coto-input" NoOp ]
                    )

        Posted postId (Ok response) ->
            ( { model | timeline = setCotoSaved postId response model.timeline }
                |> updateRecentCotonomasByCoto response
                |> clearModals
            , Cmd.none
            )

        Posted postId (Err _) ->
            ( model, Cmd.none )

        ConfirmPostAndConnect content summary ->
            confirmPostAndConnect summary content model

        PostAndConnect content summary ->
            post (Just model.connectingDirection) summary content model

        PostedAndConnect postId (Ok response) ->
            { model | timeline = setCotoSaved postId response model.timeline }
                |> clearModals
                |> connectPost response

        PostedAndConnect postId (Err _) ->
            ( model, Cmd.none )

        CotonomaPosted postId (Ok response) ->
            ({ model
                | cotonomasLoading = True
                , timeline = setCotoSaved postId response model.timeline
             }
                |> closeModal
            )
                ! [ fetchCotonomas
                  , fetchSubCotonomas model.context.cotonoma
                  ]

        CotonomaPosted postId (Err error) ->
            model.editorModal
                |> App.Modals.EditorModal.setCotoSaveError error
                |> \editorModal ->
                    ( { model
                        | editorModal = editorModal
                        , timeline = deletePendingPost postId model.timeline
                      }
                    , Cmd.none
                    )

        PostPushed payload ->
            case Decode.decodeValue (decodePayload "post" decodePost) payload of
                Ok decodedPayload ->
                    handlePushedPost model.context.clientId decodedPayload model

                Err err ->
                    model ! []

        CotonomaPushed post ->
            model
                ! [ fetchCotonomas
                  , fetchSubCotonomas model.context.cotonoma
                  ]

        --
        -- Traversals
        --
        TraverseClick traverse ->
            { model
                | traversals = updateTraversal (doTraverse traverse) model.traversals
            }
                ! []

        CloseTraversal cotoId ->
            { model
                | traversals = closeTraversal cotoId model.traversals
            }
                ! []

        SwitchTraversal pageIndex ->
            { model
                | traversals = model.traversals |> \t -> { t | activeIndexOnMobile = pageIndex }
            }
                ! []

        --
        -- CotoSelection
        --
        DeselectingCoto cotoId ->
            { model | context = setBeingDeselected cotoId model.context }
                ! [ Process.sleep (1 * Time.second)
                        |> Task.andThen (\_ -> Task.succeed ())
                        |> Task.perform (\_ -> DeselectCoto)
                  ]

        DeselectCoto ->
            ( { model | context = finishBeingDeselected model.context }
                |> closeSelectionColumnIfEmpty
            , Cmd.none
            )

        ClearSelection ->
            { model
                | context = clearSelection model.context
                , connectingSubject = Nothing
                , cotoSelectionColumnOpen = False
                , activeViewOnMobile =
                    case model.activeViewOnMobile of
                        SelectionView ->
                            TimelineView

                        anotherView ->
                            anotherView
            }
                ! []

        CotoSelectionColumnToggle ->
            { model
                | cotoSelectionColumnOpen = (not model.cotoSelectionColumnOpen)
            }
                ! []

        --
        -- Sub components
        --
        SigninModalMsg subMsg ->
            App.Modals.SigninModal.update subMsg model.signinModal
                |> \( signinModal, subCmd ) ->
                    { model | signinModal = signinModal }
                        ! [ Cmd.map SigninModalMsg subCmd ]

        EditorModalMsg subMsg ->
            App.Modals.EditorModal.update subMsg model.editorModal
                |> (\( editorModal, cmd ) ->
                        ( { model | editorModal = editorModal }, cmd )
                   )
                |> (\( model, cmd ) ->
                        case subMsg of
                            App.Modals.EditorModalMsg.Post ->
                                post
                                    Nothing
                                    (App.Modals.EditorModal.getSummary model.editorModal)
                                    model.editorModal.content
                                    model

                            App.Modals.EditorModalMsg.PostCotonoma ->
                                let
                                    cotonomaName =
                                        model.editorModal.content

                                    ( timeline, _ ) =
                                        App.Types.Timeline.post
                                            model.context
                                            True
                                            Nothing
                                            cotonomaName
                                            model.timeline
                                in
                                    { model | timeline = timeline }
                                        ! [ App.Commands.scrollTimelineToBottom NoOp
                                          , App.Server.Post.postCotonoma
                                                model.context.clientId
                                                model.context.cotonoma
                                                timeline.postIdCounter
                                                cotonomaName
                                          ]

                            App.Modals.EditorModalMsg.EditorKeyDown keyCode ->
                                handleEditorShortcut
                                    keyCode
                                    (App.Modals.EditorModal.getSummary model.editorModal)
                                    model.editorModal.content
                                    model

                            _ ->
                                ( model, cmd )
                   )

        InviteModalMsg subMsg ->
            App.Modals.InviteModal.update subMsg model.inviteModal
                |> \( inviteModal, subCmd ) ->
                    { model | inviteModal = inviteModal }
                        ! [ Cmd.map InviteModalMsg subCmd ]

        ImportModalMsg subMsg ->
            App.Modals.ImportModal.update subMsg model.importModal
                |> \( importModal, subCmd ) ->
                    { model | importModal = importModal } ! [ Cmd.map ImportModalMsg subCmd ]


changeLocationToHome : Model -> ( Model, Cmd Msg )
changeLocationToHome model =
    ( model, Navigation.newUrl "/" )


openNewEditor : Model -> ( Model, Cmd Msg )
openNewEditor model =
    ( { model
        | editorModal =
            App.Modals.EditorModal.initModel App.Modals.EditorModal.NewCoto
      }
        |> openModal EditorModal
    , App.Commands.focus "editor-modal-content-input" NoOp
    )


loadHome : Model -> ( Model, Cmd Msg )
loadHome model =
    { model
        | context =
            model.context
                |> setCotonomaLoading
                |> clearSelection
        , cotonomasLoading = True
        , subCotonomas = []
        , timeline = setLoading model.timeline
        , connectingSubject = Nothing
        , graph = defaultGraph
        , traversals = defaultTraversals
        , activeViewOnMobile = TimelineView
        , navigationOpen = False
    }
        ! [ fetchPosts
          , fetchCotonomas
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
                |> setCotonomaLoading
                |> clearSelection
        , cotonomasLoading = True
        , timeline = setLoading model.timeline
        , connectingSubject = Nothing
        , graph = defaultGraph
        , traversals = defaultTraversals
        , activeViewOnMobile = TimelineView
        , navigationOpen = False
    }
        ! [ fetchCotonomas
          , fetchCotonomaPosts key
          , fetchGraph (Just key)
          ]


handlePushedPost : String -> Payload Post -> Model -> ( Model, Cmd Msg )
handlePushedPost clientId payload model =
    if payload.clientId /= clientId then
        (model.timeline
            |> (\timeline -> ( timeline, payload.body :: timeline.posts ))
            |> (\( timeline, posts ) -> { timeline | posts = posts })
            |> (\timeline -> { model | timeline = timeline })
        )
            ! if payload.body.asCotonoma then
                [ App.Commands.scrollTimelineToBottom NoOp
                , sendMsg (CotonomaPushed payload.body)
                ]
              else
                [ App.Commands.scrollTimelineToBottom NoOp ]
    else
        model ! []


post : Maybe Direction -> Maybe String -> String -> Model -> ( Model, Cmd Msg )
post maybeDirection summary content model =
    let
        clientId =
            model.context.clientId

        cotonoma =
            model.context.cotonoma

        ( timeline, newPost ) =
            model.timeline
                |> App.Types.Timeline.post model.context False summary content

        postMsg =
            maybeDirection
                |> Maybe.map (\_ -> PostedAndConnect timeline.postIdCounter)
                |> Maybe.withDefault (Posted timeline.postIdCounter)
    in
        { model
            | timeline = timeline
            , connectingDirection =
                Maybe.withDefault Outbound maybeDirection
        }
            ! [ App.Commands.scrollTimelineToBottom NoOp
              , App.Server.Post.post clientId cotonoma postMsg newPost
              ]


confirmPostAndConnect : Maybe String -> String -> Model -> ( Model, Cmd Msg )
confirmPostAndConnect summary content model =
    ( App.Model.confirmPostAndConnect summary content model
    , App.Commands.focus "connect-modal-primary-button" NoOp
    )


handleEditorShortcut : KeyCode -> Maybe String -> String -> Model -> ( Model, Cmd Msg )
handleEditorShortcut keyCode summary content model =
    if
        (keyCode == enter.keyCode)
            && not (Set.isEmpty model.context.modifierKeys)
            && isNotBlank content
    then
        if isCtrlDown model.context then
            post Nothing summary content model
        else if isAltDown model.context && anySelection model.context then
            confirmPostAndConnect summary content model
        else
            ( model, Cmd.none )
    else
        ( model, Cmd.none )


openCoto : Coto -> Model -> ( Model, Cmd Msg )
openCoto coto model =
    ( App.Model.openCoto coto model
    , coto.cotonomaKey
        |> Maybe.map (\key -> App.Server.Cotonoma.fetchStats key)
        |> Maybe.withDefault Cmd.none
    )


connectPost : Post -> Model -> ( Model, Cmd Msg )
connectPost post model =
    post.cotoId
        |> andThen (\cotoId -> App.Model.getCoto cotoId model)
        |> Maybe.map
            (\subject ->
                let
                    direction =
                        model.connectingDirection

                    objects =
                        getSelectedCotos model

                    maybeCotonomaKey =
                        Maybe.map (\cotonoma -> cotonoma.key) model.context.cotonoma
                in
                    ( App.Model.connect direction objects subject model
                    , App.Server.Graph.connect
                        maybeCotonomaKey
                        direction
                        (List.map (\coto -> coto.id) objects)
                        subject.id
                    )
            )
        |> withDefault (model ! [])
