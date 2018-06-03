module App.Update exposing (..)

import Task
import Process
import Time
import Maybe
import Http exposing (Error(..))
import Json.Decode as Decode
import Util.Keyboard.Key
import Util.Keyboard.Event exposing (KeyboardEvent)
import Navigation
import Util.StringUtil exposing (isNotBlank)
import Util.HttpUtil exposing (ClientId)
import App.ActiveViewOnMobile exposing (ActiveViewOnMobile(..))
import App.Types.Context exposing (Context)
import App.Types.Amishi exposing (Presences)
import App.Types.Coto exposing (Coto, ElementId, CotoId, CotonomaKey)
import App.Types.Post exposing (Post)
import App.Types.Graph exposing (..)
import App.Types.Post exposing (Post)
import App.Types.Timeline
    exposing
        ( updatePost
        , setCotoSaved
        , setBeingDeleted
        , deletePendingPost
        )
import App.Types.Traversal
import App.Types.SearchResults
import App.Model exposing (..)
import App.Messages exposing (..)
import App.Confirmation exposing (Confirmation)
import App.Route exposing (Route(..))
import App.Server.Session
import App.Server.Cotonoma
import App.Server.Post
import App.Server.Coto
import App.Server.Graph
import App.Commands
import App.Channels exposing (Payload)
import App.Modals.SigninModal
import App.Modals.EditorModal
import App.Modals.EditorModalMsg
import App.Modals.InviteModal
import App.Modals.ImportModal
import App.Pushed
import App.Ports


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        KeyDown keyCode ->
            if keyCode == Util.Keyboard.Key.escapeKeyCode then
                ( closeActiveModal model, Cmd.none )
            else if
                (keyCode == Util.Keyboard.Key.nKeyCode)
                    && (List.isEmpty model.modals)
                    && (not model.timeline.editorOpen)
                    && (not model.searchInputFocus)
            then
                openNewEditor Nothing model
            else
                ( model, Cmd.none )

        AppClick ->
            ( { model | timeline = App.Types.Timeline.openOrCloseEditor False model.timeline }
            , Cmd.none
            )

        OnLocationChange location ->
            App.Route.parseLocation location
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

        ToggleTimeline ->
            ( { model | timeline = App.Types.Timeline.toggle model.timeline }
            , renderGraphWithDelay model
            )

        HomeClick ->
            changeLocationToHome model

        CotonomaPresenceState payload ->
            { model | presences = App.Channels.decodePresenceState payload } ! []

        CotonomaPresenceDiff payload ->
            App.Channels.decodePresenceDiff payload
                |> (\diff -> App.Types.Amishi.applyPresenceDiff diff model.presences)
                |> \presences -> { model | presences = presences } ! []

        SearchInputFocusChanged focus ->
            ( { model | searchInputFocus = focus }, Cmd.none )

        ClearQuickSearchInput ->
            ( { model
                | searchResults =
                    App.Types.SearchResults.clearQuery model.searchResults
              }
            , Cmd.none
            )

        QuickSearchInput query ->
            ( { model
                | searchResults =
                    App.Types.SearchResults.setQuerying query model.searchResults
              }
            , if isNotBlank query then
                App.Server.Post.search query
              else
                Cmd.none
            )

        SearchInput query ->
            ( { model
                | searchResults =
                    App.Types.SearchResults.setQuery query model.searchResults
              }
            , Cmd.none
            )

        Search ->
            ( { model | searchResults = App.Types.SearchResults.setLoading model.searchResults }
            , if App.Types.SearchResults.hasQuery model.searchResults then
                App.Server.Post.search model.searchResults.query
              else
                Cmd.none
            )

        SearchResultsFetched (Ok paginatedPosts) ->
            ( { model
                | searchResults =
                    App.Types.SearchResults.setPosts
                        paginatedPosts.posts
                        model.searchResults
              }
            , Cmd.none
            )

        SearchResultsFetched (Err _) ->
            ( model, Cmd.none )

        --
        -- Fetched
        --
        SessionFetched (Ok session) ->
            { model | context = App.Types.Context.setSession session model.context }
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
                        App.Server.Session.decodeSessionNotFoundBodyString response.body
                            |> (\body ->
                                    App.Modals.SigninModal.setSignupEnabled
                                        body.signupEnabled
                                        model.signinModal
                               )
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

        CotonomaFetched (Ok ( cotonoma, paginatedPosts )) ->
            { model
                | context = App.Types.Context.setCotonoma (Just cotonoma) model.context
                , navigationOpen = False
                , timeline = App.Types.Timeline.addPaginatedPosts paginatedPosts model.timeline
            }
                |> \model ->
                    ( model
                    , Cmd.batch
                        [ if paginatedPosts.pageIndex == 0 then
                            initScrollPositionOfTimeline model
                          else
                            Cmd.none
                        , App.Server.Cotonoma.fetchSubCotonomas (Just cotonoma)
                        ]
                    )

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
            { model | graph = graph, loadingGraph = False }
                |> \model ->
                    ( model
                    , Cmd.batch
                        [ initScrollPositionOfTimeline model
                        , App.Commands.initScrollPositionOfPinnedCotos NoOp
                        , renderGraph model
                        ]
                    )

        GraphFetched (Err _) ->
            model ! []

        SubgraphFetched (Ok subgraph) ->
            ( { model | graph = mergeSubgraph subgraph model.graph }
            , renderGraph model
            )

        SubgraphFetched (Err _) ->
            model ! []

        --
        -- Modal
        --
        CloseModal ->
            ( closeActiveModal model, Cmd.none )

        Confirm ->
            ( closeActiveModal model
            , App.Commands.sendMsg model.confirmation.msgOnConfirm
            )

        OpenSigninModal ->
            { model
                | signinModal =
                    App.Modals.SigninModal.initModel model.signinModal.signupEnabled
            }
                |> \model -> ( openModal App.Model.SigninModal model, Cmd.none )

        OpenNewEditorModal ->
            openNewEditor Nothing model

        OpenNewEditorModalWithSourceCoto coto ->
            openNewEditor (Just coto) model

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
                | editorModal = App.Modals.EditorModal.modelForEdit coto
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
                        |> App.Types.Context.setElementFocus (Just elementId)
                        |> App.Types.Context.setCotoFocus (Just cotoId)
            }
                ! []

        CotoMouseLeave elementId cotoId ->
            { model
                | context =
                    model.context
                        |> App.Types.Context.setElementFocus Nothing
                        |> App.Types.Context.setCotoFocus Nothing
            }
                ! []

        SelectCoto cotoId ->
            ( { model
                | context =
                    App.Types.Context.updateSelection cotoId model.context
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
                        , App.Commands.scrollTraversalsPaginationToRight NoOp
                        , App.Server.Graph.fetchSubgraphIfCotonoma model.graph cotoId
                        ]
                    )

        CotonomaClick key ->
            changeLocationToCotonoma key model

        ToggleCotoContent elementId ->
            ( { model | context = App.Types.Context.toggleContent elementId model.context }
            , Cmd.none
            )

        ConfirmDeleteCoto coto ->
            ( confirm
                (Confirmation
                    "Are you sure you want to delete this coto?"
                    (DeleteCotoInServerSide coto)
                )
                model
            , Cmd.none
            )

        DeleteCotoInServerSide coto ->
            ( { model | timeline = setBeingDeleted coto model.timeline }
                |> clearModals
            , Cmd.batch
                [ App.Server.Coto.deleteCoto model.context.clientId coto.id
                , Process.sleep (1 * Time.second)
                    |> Task.andThen (\_ -> Task.succeed ())
                    |> Task.perform (\_ -> DeleteCotoInClientSide coto)
                ]
            )

        DeleteCotoInClientSide coto ->
            ( App.Model.deleteCoto coto model, Cmd.none )

        CotoDeleted (Ok _) ->
            ( model
            , Cmd.batch
                [ App.Server.Cotonoma.fetchCotonomas
                , App.Server.Cotonoma.fetchSubCotonomas model.context.cotonoma
                ]
            )

        CotoDeleted (Err error) ->
            ( model, Cmd.none )

        CotoUpdated (Ok coto) ->
            ( (model
                |> updateCotoContent coto
                |> updateRecentCotonomasByCoto coto
                |> clearModals
              )
            , if coto.asCotonoma then
                Cmd.batch
                    [ App.Server.Cotonoma.fetchCotonomas
                    , App.Server.Cotonoma.fetchSubCotonomas model.context.cotonoma
                    ]
              else
                Cmd.none
            )

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
                ( { model | editorModal = App.Modals.EditorModal.modelForEditToCotonomatize coto }
                    |> openModal EditorModal
                , Cmd.none
                )

        Cotonomatize cotoId ->
            ( model, App.Server.Coto.cotonomatize model.context.clientId cotoId )

        Cotonomatized (Ok coto) ->
            ( model
                |> App.Model.cotonomatize coto.id coto.cotonomaKey
                |> clearModals
            , Cmd.batch
                [ App.Server.Cotonoma.fetchCotonomas
                , App.Server.Cotonoma.fetchSubCotonomas model.context.cotonoma
                ]
            )

        Cotonomatized (Err error) ->
            model.cotoMenuModal
                |> Maybe.map (\cotoMenuModal -> App.Modals.EditorModal.modelForEdit cotoMenuModal.coto)
                |> Maybe.map (App.Modals.EditorModal.setCotoSaveError error)
                |> Maybe.map (\editorModal -> { model | editorModal = editorModal })
                |> Maybe.map (openModal EditorModal)
                |> Maybe.withDefault model
                |> \model -> ( model, Cmd.none )

        PinCoto cotoId ->
            (Maybe.map2
                (\session coto ->
                    ( { model | graph = pinCoto session.id coto model.graph }
                    , Cmd.batch
                        [ App.Server.Graph.pinCotos
                            model.context.clientId
                            (Maybe.map (\cotonoma -> cotonoma.key) model.context.cotonoma)
                            [ cotoId ]
                        , App.Commands.scrollPinnedCotosToBottom NoOp
                        ]
                    )
                )
                model.context.session
                (App.Model.getCoto cotoId model)
            )
                |> Maybe.withDefault ( model, Cmd.none )

        PinCotoToMyHome cotoId ->
            ( clearModals model
            , App.Server.Graph.pinCotos model.context.clientId Nothing [ cotoId ]
            )

        CotoPinned (Ok _) ->
            ( model, renderGraph model )

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
                        model.context.clientId
                        (Maybe.map (\cotonoma -> cotonoma.key) model.context.cotonoma)
                        cotoId
                  ]

        CotoUnpinned (Ok _) ->
            ( model, renderGraph model )

        CotoUnpinned (Err _) ->
            ( model, Cmd.none )

        ConfirmConnect cotoId direction ->
            { model
                | connectingTarget =
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

        Connect target objects direction ->
            ( App.Model.connect direction objects target model
                |> closeModal App.Model.ConnectModal
            , App.Server.Graph.connect
                model.context.clientId
                (Maybe.map (\cotonoma -> cotonoma.key) model.context.cotonoma)
                direction
                (List.map (\coto -> coto.id) objects)
                target.id
            )

        Connected (Ok _) ->
            ( model, renderGraph model )

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
            ( { model
                | graph = disconnect ( startId, endId ) model.graph
              }
            , App.Server.Graph.disconnect
                model.context.clientId
                (Maybe.map (\cotonoma -> cotonoma.key) model.context.cotonoma)
                startId
                endId
            )

        ConnectionDeleted (Ok _) ->
            ( model, renderGraph model )

        ConnectionDeleted (Err _) ->
            ( model, Cmd.none )

        ToggleReorderMode elementId ->
            ( { model
                | context =
                    App.Types.Context.toggleReorderMode elementId model.context
              }
            , Cmd.none
            )

        SwapOrder maybeParentId index1 index2 ->
            model.graph
                |> App.Types.Graph.swapOrder maybeParentId index1 index2
                |> (\graph -> { model | graph = graph })
                |> (\model -> ( model, makeReorderCmd maybeParentId model ))

        MoveToFirst maybeParentId index ->
            model.graph
                |> App.Types.Graph.moveToFirst maybeParentId index
                |> (\graph -> { model | graph = graph })
                |> (\model -> ( model, makeReorderCmd maybeParentId model ))

        MoveToLast maybeParentId index ->
            model.graph
                |> App.Types.Graph.moveToLast maybeParentId index
                |> (\graph -> { model | graph = graph })
                |> (\model -> ( model, makeReorderCmd maybeParentId model ))

        ConnectionsReordered (Ok _) ->
            ( model, Cmd.none )

        ConnectionsReordered (Err _) ->
            ( model, Cmd.none )

        --
        -- Cotonoma
        --
        PinOrUnpinCotonoma cotonomaKey pinOrUnpin ->
            ( model
            , App.Server.Cotonoma.pinOrUnpinCotonoma
                model.context.clientId
                pinOrUnpin
                cotonomaKey
            )

        CotonomaPinnedOrUnpinned (Ok _) ->
            ( { model | cotonomasLoading = True }
                |> closeModal App.Model.CotoMenuModal
            , App.Server.Cotonoma.fetchCotonomas
            )

        CotonomaPinnedOrUnpinned (Err _) ->
            ( model, Cmd.none )

        LoadMorePostsInCotonoma cotonomaKey ->
            { model | timeline = App.Types.Timeline.setLoadingMore model.timeline }
                |> \model ->
                    ( model
                    , App.Server.Post.fetchCotonomaPosts
                        cotonomaKey
                        (App.Types.Timeline.nextPageIndex model.timeline)
                    )

        --
        -- Timeline
        --
        SwitchTimelineView view ->
            ( { model | timeline = App.Types.Timeline.switchView view model.timeline }, Cmd.none )

        PostsFetched (Ok paginatedPosts) ->
            { model
                | context = App.Types.Context.setCotonoma Nothing model.context
                , timeline = App.Types.Timeline.addPaginatedPosts paginatedPosts model.timeline
            }
                |> \model ->
                    ( model
                    , if paginatedPosts.pageIndex == 0 then
                        initScrollPositionOfTimeline model
                      else
                        Cmd.none
                    )

        PostsFetched (Err _) ->
            model ! []

        LoadMorePosts ->
            { model | timeline = App.Types.Timeline.setLoadingMore model.timeline }
                |> \model ->
                    ( model
                    , App.Server.Post.fetchPosts
                        (App.Types.Timeline.nextPageIndex model.timeline)
                    )

        ImageLoaded ->
            model ! [ App.Commands.scrollTimelineToBottom NoOp ]

        EditorFocus ->
            App.Types.Timeline.openOrCloseEditor True model.timeline
                |> \timeline ->
                    ( { model | timeline = timeline }
                    , if timeline.editorOpen then
                        App.Commands.scrollTimelineByQuickEditorOpen NoOp
                      else
                        Cmd.none
                    )

        EditorInput content ->
            { model | timeline = model.timeline |> \t -> { t | newContent = content } } ! []

        EditorKeyDown keyboardEvent ->
            handleEditorShortcut keyboardEvent Nothing model.timeline.newContent model
                |> \( model, cmd ) ->
                    ( model
                    , Cmd.batch [ cmd, App.Commands.focus "quick-coto-input" NoOp ]
                    )

        Post ->
            postAndConnectToSelection Nothing Nothing model.timeline.newContent model
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

        PostAndConnectToSelection content summary ->
            model
                |> closeModal App.Model.ConnectModal
                |> postAndConnectToSelection
                    (Just model.connectingDirection)
                    summary
                    content

        PostedAndConnectToSelection postId (Ok response) ->
            { model | timeline = setCotoSaved postId response model.timeline }
                |> clearModals
                |> connectPostToSelection model.context.clientId response

        PostedAndConnectToSelection postId (Err _) ->
            ( model, Cmd.none )

        PostedAndConnectToCoto postId coto (Ok response) ->
            { model | timeline = setCotoSaved postId response model.timeline }
                |> clearModals
                |> connectPostToCoto model.context.clientId coto response

        PostedAndConnectToCoto postId coto (Err _) ->
            ( model, Cmd.none )

        CotonomaPosted postId (Ok response) ->
            ( { model
                | cotonomasLoading = True
                , timeline = setCotoSaved postId response model.timeline
              }
                |> clearModals
            , Cmd.batch
                [ App.Server.Cotonoma.fetchCotonomas
                , App.Server.Cotonoma.fetchSubCotonomas model.context.cotonoma
                ]
            )

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

        TimelineScrollPosInitialized ->
            model.timeline
                |> (\timeline -> { timeline | initializingScrollPos = False })
                |> \timeline -> ( { model | timeline = timeline }, Cmd.none )

        --
        -- PinnedCotos
        --
        SwitchPinnedCotosView view ->
            ( { model | pinnedCotosView = view }
            , if view == GraphView then
                renderGraphWithDelay model
              else
                Cmd.none
            )

        RenderGraph ->
            ( model, renderGraph model )

        --
        -- Traversals
        --
        Traverse traversal nextCotoId stepIndex ->
            ( { model
                | traversals =
                    App.Types.Traversal.updateTraversal
                        traversal.start
                        (App.Types.Traversal.traverse stepIndex nextCotoId traversal)
                        model.traversals
              }
            , Cmd.none
            )

        TraverseToParent traversal parentId ->
            ( { model
                | traversals =
                    App.Types.Traversal.updateTraversal
                        traversal.start
                        (App.Types.Traversal.traverseToParent model.graph parentId traversal)
                        model.traversals
              }
            , Cmd.none
            )

        CloseTraversal cotoId ->
            ( { model
                | traversals = App.Types.Traversal.closeTraversal cotoId model.traversals
              }
            , Cmd.none
            )

        SwitchTraversal pageIndex ->
            ( { model
                | traversals = model.traversals |> \t -> { t | activeIndexOnMobile = pageIndex }
              }
            , Cmd.none
            )

        --
        -- CotoSelection
        --
        DeselectingCoto cotoId ->
            { model | context = App.Types.Context.setBeingDeselected cotoId model.context }
                ! [ Process.sleep (1 * Time.second)
                        |> Task.andThen (\_ -> Task.succeed ())
                        |> Task.perform (\_ -> DeselectCoto)
                  ]

        DeselectCoto ->
            ( { model | context = App.Types.Context.finishBeingDeselected model.context }
                |> closeSelectionColumnIfEmpty
            , Cmd.none
            )

        ClearSelection ->
            { model
                | context = App.Types.Context.clearSelection model.context
                , connectingTarget = Nothing
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
        -- Pushed
        --
        UpdatePushed payload ->
            App.Pushed.handle
                App.Server.Coto.decodeCoto
                App.Pushed.handleUpdate
                payload
                model

        DeletePushed payload ->
            App.Pushed.handle Decode.string App.Pushed.handleDelete payload model

        CotonomatizePushed payload ->
            App.Pushed.handle
                App.Server.Cotonoma.decodeCotonoma
                App.Pushed.handleCotonomatize
                payload
                model

        CotonomaPushed payload ->
            App.Pushed.handle
                App.Server.Cotonoma.decodeCotonoma
                App.Pushed.handleCotonoma
                payload
                model

        ConnectPushed payload ->
            App.Pushed.handle
                App.Pushed.decodeConnectPayloadBody
                App.Pushed.handleConnect
                payload
                model

        DisconnectPushed payload ->
            App.Pushed.handle
                App.Pushed.decodeDisconnectPayloadBody
                App.Pushed.handleDisconnect
                payload
                model

        ReorderPushed payload ->
            App.Pushed.handle
                App.Pushed.decodeReorderPayloadBody
                App.Pushed.handleReorder
                payload
                model

        PostPushed payload ->
            App.Pushed.handle
                App.Server.Post.decodePost
                App.Pushed.handlePost
                payload
                model

        --
        -- Sub components
        --
        SigninModalMsg subMsg ->
            App.Modals.SigninModal.update subMsg model.signinModal
                |> \( signinModal, subCmd ) ->
                    { model | signinModal = signinModal }
                        ! [ Cmd.map SigninModalMsg subCmd ]

        EditorModalMsg subMsg ->
            App.Modals.EditorModal.update model.context subMsg model.editorModal
                |> (\( editorModal, cmd ) ->
                        ( { model | editorModal = editorModal }, cmd )
                   )
                |> (\( model, cmd ) ->
                        case subMsg of
                            App.Modals.EditorModalMsg.Post ->
                                postFromEditorModal model

                            App.Modals.EditorModalMsg.PostCotonoma ->
                                postCotonomaFromEditorModal model

                            App.Modals.EditorModalMsg.EditorKeyDown keyboardEvent ->
                                handleEditorModalShortcut keyboardEvent model

                            _ ->
                                ( model, cmd )
                   )

        InviteModalMsg subMsg ->
            App.Modals.InviteModal.update subMsg model.inviteModal
                |> \( inviteModal, subCmd ) ->
                    { model | inviteModal = inviteModal }
                        ! [ Cmd.map InviteModalMsg subCmd ]

        ImportModalMsg subMsg ->
            App.Modals.ImportModal.update model.context subMsg model.importModal
                |> \( importModal, subCmd ) ->
                    { model | importModal = importModal } ! [ Cmd.map ImportModalMsg subCmd ]


changeLocationToHome : Model -> ( Model, Cmd Msg )
changeLocationToHome model =
    ( model, Navigation.newUrl "/" )


openNewEditor : Maybe Coto -> Model -> ( Model, Cmd Msg )
openNewEditor source model =
    ( { model
        | editorModal = App.Modals.EditorModal.modelForNew source
      }
        |> openModal EditorModal
    , App.Commands.focus "editor-modal-content-input" NoOp
    )


loadHome : Model -> ( Model, Cmd Msg )
loadHome model =
    ( { model
        | context =
            model.context
                |> App.Types.Context.setCotonomaLoading
                |> App.Types.Context.clearSelection
        , cotonomasLoading = True
        , subCotonomas = []
        , timeline = App.Types.Timeline.setLoading model.timeline
        , connectingTarget = Nothing
        , graph = defaultGraph
        , loadingGraph = True
        , traversals = App.Types.Traversal.defaultTraversals
        , activeViewOnMobile = TimelineView
        , navigationOpen = False
      }
    , Cmd.batch
        [ App.Server.Post.fetchPosts 0
        , App.Server.Cotonoma.fetchCotonomas
        , App.Server.Graph.fetchGraph Nothing
        , App.Ports.destroyGraph ()
        ]
    )


changeLocationToCotonoma : CotonomaKey -> Model -> ( Model, Cmd Msg )
changeLocationToCotonoma key model =
    ( model, Navigation.newUrl ("/cotonomas/" ++ key) )


loadCotonoma : CotonomaKey -> Model -> ( Model, Cmd Msg )
loadCotonoma key model =
    ( { model
        | context =
            model.context
                |> App.Types.Context.setCotonomaLoading
                |> App.Types.Context.clearSelection
        , cotonomasLoading = True
        , timeline = App.Types.Timeline.setLoading model.timeline
        , connectingTarget = Nothing
        , graph = defaultGraph
        , loadingGraph = True
        , traversals = App.Types.Traversal.defaultTraversals
        , activeViewOnMobile = TimelineView
        , navigationOpen = False
      }
    , Cmd.batch
        [ App.Server.Cotonoma.fetchCotonomas
        , App.Server.Post.fetchCotonomaPosts key 0
        , App.Server.Graph.fetchGraph (Just key)
        , App.Ports.destroyGraph ()
        ]
    )


initScrollPositionOfTimeline : Model -> Cmd Msg
initScrollPositionOfTimeline model =
    if App.Model.areTimelineAndGraphLoaded model then
        App.Commands.scrollTimelineToBottom TimelineScrollPosInitialized
    else
        Cmd.none


postAndConnectToSelection : Maybe Direction -> Maybe String -> String -> Model -> ( Model, Cmd Msg )
postAndConnectToSelection maybeDirection summary content model =
    let
        ( timeline, newPost ) =
            model.timeline
                |> App.Types.Timeline.post model.context False summary content

        postMsg =
            maybeDirection
                |> Maybe.map (\_ -> PostedAndConnectToSelection timeline.postIdCounter)
                |> Maybe.withDefault (Posted timeline.postIdCounter)
    in
        { model
            | timeline = timeline
            , connectingDirection =
                Maybe.withDefault Outbound maybeDirection
        }
            ! [ App.Commands.scrollTimelineToBottom NoOp
              , App.Server.Post.post
                    model.context.clientId
                    model.context.cotonoma
                    postMsg
                    newPost
              ]


postAndConnectToCoto : Coto -> Maybe String -> String -> Model -> ( Model, Cmd Msg )
postAndConnectToCoto coto summary content model =
    let
        ( timeline, newPost ) =
            model.timeline
                |> App.Types.Timeline.post model.context False summary content
    in
        { model | timeline = timeline }
            ! [ App.Commands.scrollTimelineToBottom NoOp
              , App.Server.Post.post
                    model.context.clientId
                    model.context.cotonoma
                    (PostedAndConnectToCoto timeline.postIdCounter coto)
                    newPost
              ]


postFromEditorModal : Model -> ( Model, Cmd Msg )
postFromEditorModal model =
    let
        summary =
            App.Modals.EditorModal.getSummary model.editorModal

        content =
            model.editorModal.content
    in
        model.editorModal.source
            |> Maybe.map
                (\source ->
                    postAndConnectToCoto source summary content model
                )
            |> Maybe.withDefault
                (postAndConnectToSelection Nothing summary content model)


postCotonomaFromEditorModal : Model -> ( Model, Cmd Msg )
postCotonomaFromEditorModal model =
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


confirmPostAndConnect : Maybe String -> String -> Model -> ( Model, Cmd Msg )
confirmPostAndConnect summary content model =
    ( App.Model.confirmPostAndConnect summary content model
    , App.Commands.focus "connect-modal-primary-button" NoOp
    )


handleEditorShortcut : KeyboardEvent -> Maybe String -> String -> Model -> ( Model, Cmd Msg )
handleEditorShortcut keyboardEvent summary content model =
    if
        (keyboardEvent.keyCode == Util.Keyboard.Key.Enter)
            && isNotBlank content
    then
        if keyboardEvent.ctrlKey || keyboardEvent.metaKey then
            postAndConnectToSelection Nothing summary content model
        else if
            keyboardEvent.altKey
                && App.Types.Context.anySelection model.context
        then
            confirmPostAndConnect summary content model
        else
            ( model, Cmd.none )
    else
        ( model, Cmd.none )


handleEditorModalShortcut : KeyboardEvent -> Model -> ( Model, Cmd Msg )
handleEditorModalShortcut keyboardEvent model =
    if
        (keyboardEvent.keyCode == Util.Keyboard.Key.Enter)
            && isNotBlank model.editorModal.content
    then
        case model.editorModal.mode of
            App.Modals.EditorModal.Edit coto ->
                if keyboardEvent.ctrlKey || keyboardEvent.metaKey then
                    ( model
                    , App.Server.Coto.updateContent
                        model.context.clientId
                        coto.id
                        model.editorModal.summary
                        model.editorModal.content
                    )
                else
                    ( model, Cmd.none )

            _ ->
                if keyboardEvent.ctrlKey || keyboardEvent.metaKey then
                    postFromEditorModal model
                else if
                    keyboardEvent.altKey
                        && App.Types.Context.anySelection model.context
                then
                    confirmPostAndConnect
                        (App.Modals.EditorModal.getSummary model.editorModal)
                        model.editorModal.content
                        model
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


connectPostToSelection : ClientId -> Post -> Model -> ( Model, Cmd Msg )
connectPostToSelection clientId post model =
    post.cotoId
        |> Maybe.andThen (\cotoId -> App.Model.getCoto cotoId model)
        |> Maybe.map
            (\target ->
                let
                    direction =
                        model.connectingDirection

                    objects =
                        getSelectedCotos model

                    maybeCotonomaKey =
                        Maybe.map (\cotonoma -> cotonoma.key) model.context.cotonoma
                in
                    ( App.Model.connect direction objects target model
                    , App.Server.Graph.connect
                        clientId
                        maybeCotonomaKey
                        direction
                        (List.map (\coto -> coto.id) objects)
                        target.id
                    )
            )
        |> Maybe.withDefault ( model, Cmd.none )


connectPostToCoto : ClientId -> Coto -> Post -> Model -> ( Model, Cmd Msg )
connectPostToCoto clientId coto post model =
    post.cotoId
        |> Maybe.andThen (\cotoId -> App.Model.getCoto cotoId model)
        |> Maybe.map
            (\target ->
                let
                    direction =
                        App.Types.Graph.Inbound

                    maybeCotonomaKey =
                        Maybe.map (\cotonoma -> cotonoma.key) model.context.cotonoma
                in
                    ( App.Model.connect direction [ coto ] target model
                    , App.Server.Graph.connect
                        clientId
                        maybeCotonomaKey
                        direction
                        [ coto.id ]
                        target.id
                    )
            )
        |> Maybe.withDefault ( model, Cmd.none )


makeReorderCmd : Maybe CotoId -> Model -> Cmd Msg
makeReorderCmd maybeParentId model =
    model.graph
        |> App.Types.Graph.getOutboundConnections maybeParentId
        |> Maybe.map (List.map (\connection -> connection.end))
        |> Maybe.map List.reverse
        |> Maybe.map
            (App.Server.Graph.reorder
                model.context.clientId
                (Maybe.map (\cotonoma -> cotonoma.key) model.context.cotonoma)
                maybeParentId
            )
        |> Maybe.withDefault Cmd.none


renderGraph : Model -> Cmd Msg
renderGraph model =
    if model.pinnedCotosView == GraphView then
        App.Ports.renderCotoGraph model.context.cotonoma model.graph
    else
        Cmd.none


renderGraphWithDelay : Model -> Cmd Msg
renderGraphWithDelay model =
    Process.sleep (100 * Time.millisecond)
        |> Task.andThen (\_ -> Task.succeed ())
        |> Task.perform (\_ -> RenderGraph)
