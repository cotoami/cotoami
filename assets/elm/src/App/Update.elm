module App.Update exposing (..)

import Task
import Process
import Time
import Maybe
import Http exposing (Error(..))
import Json.Decode as Decode
import Exts.Maybe exposing (isJust)
import Utils.Keyboard.Key
import Navigation
import Utils.StringUtil exposing (isNotBlank)
import Utils.UpdateUtil exposing (..)
import App.LocalConfig
import App.I18n.Keys as I18nKeys
import App.Types.Amishi exposing (Presences)
import App.Types.Coto exposing (Coto, ElementId, CotoId, CotonomaKey)
import App.Types.Graph exposing (Direction(..))
import App.Types.Timeline
import App.Types.Traversal
import App.Types.SearchResults
import App.Model exposing (Model)
import App.Messages exposing (..)
import App.Submodels.Context exposing (Context)
import App.Submodels.LocalCotos
import App.Submodels.Modals exposing (Modal(..), Confirmation)
import App.Route exposing (Route(..))
import App.Server.Session
import App.Server.Cotonoma
import App.Server.Post
import App.Server.Coto
import App.Server.Graph
import App.Commands
import App.Commands.Cotonoma
import App.Channels exposing (Payload)
import App.Views.ViewSwitch
import App.Views.ViewSwitchMsg exposing (ActiveView(..))
import App.Views.Flow
import App.Views.Stock
import App.Views.Traversals
import App.Views.CotoSelection
import App.Views.CotoToolbar
import App.Modals.SigninModal
import App.Modals.CotoMenuModal
import App.Modals.CotoModal
import App.Modals.EditorModal
import App.Modals.InviteModal
import App.Modals.ImportModal
import App.Modals.TimelineFilterModal
import App.Modals.ConnectModal exposing (ConnectingTarget(..))
import App.Pushed
import App.Ports.Graph


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            model |> withoutCmd

        LocalStorageItemFetched item ->
            App.LocalConfig.configure item model
                |> withoutCmd

        KeyDown keyCode ->
            if keyCode == Utils.Keyboard.Key.escapeKeyCode then
                ( App.Submodels.Modals.closeActiveModal model, Cmd.none )
            else if
                (keyCode == Utils.Keyboard.Key.nKeyCode)
                    && (List.isEmpty model.modals)
                    && (not model.flowView.editorOpen)
                    && (not model.searchInputFocus)
            then
                App.Modals.EditorModal.openForNew model Nothing model
            else
                model |> withoutCmd

        AppClick ->
            { model | flowView = App.Views.Flow.openOrCloseEditor False model.flowView }
                |> withoutCmd

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
                            model |> withoutCmd

        NavigationToggle ->
            { model
                | navigationToggled = True
                , navigationOpen = (not model.navigationOpen)
            }
                |> withoutCmd

        HomeClick ->
            changeLocationToHome model

        CotonomaPresenceState payload ->
            { model | presences = App.Channels.decodePresenceState payload }
                |> withoutCmd

        CotonomaPresenceDiff payload ->
            App.Channels.decodePresenceDiff payload
                |> (\diff -> App.Types.Amishi.applyPresenceDiff diff model.presences)
                |> (\presences -> { model | presences = presences })
                |> withoutCmd

        SessionFetched (Ok session) ->
            { model | session = Just session }
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
                            |> App.Submodels.Modals.openModal SigninModal
                            |> withoutCmd
                    else
                        model |> withoutCmd

                _ ->
                    model |> withoutCmd

        HomePostsFetched (Ok paginatedPosts) ->
            { model | timeline = App.Types.Timeline.setPaginatedPosts paginatedPosts model.timeline }
                |> App.Submodels.Context.setCotonoma Nothing
                |> withCmdIf
                    (\_ -> paginatedPosts.pageIndex == 0)
                    App.Views.Flow.initScrollPos

        HomePostsFetched (Err _) ->
            model |> withoutCmd

        CotonomaPostsFetched (Ok ( cotonoma, paginatedPosts )) ->
            { model
                | navigationOpen = False
                , timeline = App.Types.Timeline.setPaginatedPosts paginatedPosts model.timeline
            }
                |> App.Submodels.Context.setCotonoma (Just cotonoma)
                |> withCmdIf
                    (\_ -> paginatedPosts.pageIndex == 0)
                    App.Views.Flow.initScrollPos
                |> addCmd (\model -> App.Server.Cotonoma.fetchSubCotonomas model)

        CotonomaPostsFetched (Err _) ->
            model |> withoutCmd

        CotonomasFetched (Ok recentCotonomas) ->
            { model
                | recentCotonomas = recentCotonomas
                , cotonomasLoading = False
            }
                |> withoutCmd

        CotonomasFetched (Err _) ->
            { model | cotonomasLoading = False } |> withoutCmd

        SubCotonomasFetched (Ok cotonomas) ->
            { model | subCotonomas = cotonomas } |> withoutCmd

        SubCotonomasFetched (Err _) ->
            model |> withoutCmd

        GraphFetched (Ok graph) ->
            { model | graph = graph, loadingGraph = False }
                |> withCmd
                    (\model ->
                        Cmd.batch
                            [ App.Views.Flow.initScrollPos model
                            , App.Commands.initScrollPositionOfPinnedCotos NoOp
                            , App.Views.Stock.renderGraph model model
                            ]
                    )

        GraphFetched (Err _) ->
            model |> withoutCmd

        SubgraphFetched (Ok subgraph) ->
            { model | graph = App.Types.Graph.mergeSubgraph subgraph model.graph }
                |> withCmd (\model -> App.Views.Stock.renderGraph model model)

        SubgraphFetched (Err _) ->
            model |> withoutCmd

        --
        -- Search
        --
        SearchInputFocusChanged focus ->
            { model | searchInputFocus = focus } |> withoutCmd

        ClearQuickSearchInput ->
            { model
                | searchResults =
                    App.Types.SearchResults.clearQuery model.searchResults
            }
                |> withoutCmd

        QuickSearchInput query ->
            { model | searchResults = App.Types.SearchResults.setQuerying query model.searchResults }
                |> withCmdIf
                    (\_ -> isNotBlank query)
                    (\_ -> App.Server.Post.search query)

        SearchInput query ->
            { model | searchResults = App.Types.SearchResults.setQuery query model.searchResults }
                |> withoutCmd

        Search ->
            { model | searchResults = App.Types.SearchResults.setLoading model.searchResults }
                |> withCmdIf
                    (\model -> App.Types.SearchResults.hasQuery model.searchResults)
                    (\model -> App.Server.Post.search model.searchResults.query)

        SearchResultsFetched (Ok paginatedPosts) ->
            { model
                | searchResults =
                    App.Types.SearchResults.setPosts
                        paginatedPosts.posts
                        model.searchResults
            }
                |> withoutCmd

        SearchResultsFetched (Err _) ->
            model |> withoutCmd

        --
        -- Modal
        --
        CloseModal ->
            App.Submodels.Modals.closeActiveModal model |> withoutCmd

        Confirm ->
            App.Submodels.Modals.closeActiveModal model
                |> withCmd (\model -> App.Commands.sendMsg model.confirmation.msgOnConfirm)

        OpenSigninModal ->
            { model | signinModal = App.Modals.SigninModal.initModel model.signinModal.signupEnabled }
                |> App.Submodels.Modals.openModal SigninModal
                |> withoutCmd

        OpenNewEditorModal ->
            App.Modals.EditorModal.openForNew model Nothing model

        OpenNewEditorModalWithSourceCoto coto ->
            App.Modals.EditorModal.openForNew model (Just coto) model

        OpenInviteModal ->
            { model | inviteModal = App.Modals.InviteModal.defaultModel }
                |> App.Submodels.Modals.openModal InviteModal
                |> withoutCmd

        OpenProfileModal ->
            App.Submodels.Modals.openModal ProfileModal model |> withoutCmd

        OpenEditorModal coto ->
            { model | editorModal = App.Modals.EditorModal.modelForEdit coto }
                |> App.Submodels.Modals.openModal EditorModal
                |> withCmd (\_ -> App.Commands.focus "editor-modal-content-input" NoOp)

        OpenCotoModal coto ->
            App.Modals.CotoModal.open coto model
                |> withoutCmd

        OpenImportModal ->
            { model | importModal = App.Modals.ImportModal.defaultModel }
                |> App.Submodels.Modals.openModal ImportModal
                |> withoutCmd

        OpenTimelineFilterModal ->
            model
                |> App.Submodels.Modals.openModal TimelineFilterModal
                |> withoutCmd

        --
        -- Coto
        --
        CotoClick elementId cotoId ->
            model
                |> App.Submodels.Context.focusCoto elementId cotoId
                |> withoutCmd

        CotoMouseEnter elementId cotoId ->
            model
                |> App.Submodels.Context.focusCoto elementId cotoId
                |> withoutCmd

        CotoMouseLeave elementId cotoId ->
            model
                |> App.Submodels.Context.clearCotoFocus
                |> withoutCmd

        SelectCoto cotoId ->
            model
                |> App.Submodels.Context.updateSelection cotoId
                |> App.Views.CotoSelection.closeColumnIfEmpty
                |> withoutCmd

        OpenTraversal cotoId ->
            model
                |> App.Model.openTraversal cotoId
                |> App.Submodels.Modals.clearModals
                |> withCmd
                    (\model ->
                        Cmd.batch
                            [ App.Commands.scrollGraphExplorationToRight NoOp
                            , App.Commands.scrollTraversalsPaginationToRight NoOp
                            , App.Server.Graph.fetchSubgraphIfCotonoma model.graph cotoId
                            , App.Views.Stock.resizeGraphWithDelay
                            ]
                    )

        CotonomaClick key ->
            changeLocationToCotonoma key model

        ToggleCotoContent elementId ->
            model
                |> App.Submodels.Context.toggleContent elementId
                |> withoutCmd

        ConfirmDeleteCoto coto ->
            (App.Submodels.Modals.confirm
                (Confirmation
                    (model.i18nText I18nKeys.ConfirmDeleteCoto)
                    (DeleteCotoInServerSide coto)
                )
                model
            )
                |> withoutCmd

        DeleteCotoInServerSide coto ->
            { model | timeline = App.Types.Timeline.setBeingDeleted coto model.timeline }
                |> App.Submodels.Modals.clearModals
                |> withCmd
                    (\model ->
                        Cmd.batch
                            [ App.Server.Coto.deleteCoto model.clientId coto.id
                            , Process.sleep (1 * Time.second)
                                |> Task.andThen (\_ -> Task.succeed ())
                                |> Task.perform (\_ -> DeleteCotoInClientSide coto)
                            ]
                    )

        DeleteCotoInClientSide coto ->
            model
                |> App.Model.deleteCoto coto
                |> withCmd (App.Views.Stock.renderGraph model)

        CotoDeleted (Ok _) ->
            model |> withCmd App.Commands.Cotonoma.refreshCotonomaList

        CotoDeleted (Err error) ->
            model |> withoutCmd

        CotoUpdated (Ok coto) ->
            model
                |> App.Submodels.LocalCotos.updateCoto coto
                |> App.Submodels.LocalCotos.updateRecentCotonomas coto.postedIn
                |> App.Submodels.Modals.clearModals
                |> withCmdIf
                    (\_ -> isJust coto.asCotonoma)
                    App.Commands.Cotonoma.refreshCotonomaList
                |> addCmd (App.Views.Stock.renderGraph model)

        CotoUpdated (Err error) ->
            model.editorModal
                |> App.Modals.EditorModal.setCotoSaveError error
                |> (\editorModal -> { model | editorModal = editorModal })
                |> withoutCmd

        ConfirmCotonomatize coto ->
            if String.length coto.content <= App.Types.Coto.cotonomaNameMaxlength then
                (App.Submodels.Modals.confirm
                    (Confirmation
                        (model.i18nText (I18nKeys.ConfirmCotonomatize coto.content))
                        (Cotonomatize coto.id)
                    )
                    model
                )
                    |> withoutCmd
            else
                { model | editorModal = App.Modals.EditorModal.modelForEditToCotonomatize coto }
                    |> App.Submodels.Modals.openModal EditorModal
                    |> withoutCmd

        Cotonomatize cotoId ->
            ( model, App.Server.Coto.cotonomatize model.clientId cotoId )

        Cotonomatized (Ok coto) ->
            coto.asCotonoma
                |> Maybe.map (\cotonoma -> App.Submodels.LocalCotos.cotonomatize cotonoma coto.id model)
                |> Maybe.withDefault model
                |> App.Submodels.Modals.clearModals
                |> withCmd App.Commands.Cotonoma.refreshCotonomaList
                |> addCmd (App.Views.Stock.renderGraph model)

        Cotonomatized (Err error) ->
            model.cotoMenuModal
                |> Maybe.map (\cotoMenuModal -> App.Modals.EditorModal.modelForEdit cotoMenuModal.coto)
                |> Maybe.map (App.Modals.EditorModal.setCotoSaveError error)
                |> Maybe.map (\editorModal -> { model | editorModal = editorModal })
                |> Maybe.map (App.Submodels.Modals.openModal EditorModal)
                |> Maybe.withDefault model
                |> withoutCmd

        PinCoto cotoId ->
            (Maybe.map2
                (\session coto ->
                    { model | graph = App.Types.Graph.pinCoto session.id coto model.graph }
                        |> withCmd
                            (\model ->
                                Cmd.batch
                                    [ App.Server.Graph.pinCotos
                                        model.clientId
                                        (Maybe.map (\cotonoma -> cotonoma.key) model.cotonoma)
                                        [ cotoId ]
                                    , App.Commands.scrollPinnedCotosToBottom NoOp
                                    ]
                            )
                )
                model.session
                (App.Submodels.LocalCotos.getCoto cotoId model)
            )
                |> Maybe.withDefault (model |> withoutCmd)

        PinCotoToMyHome cotoId ->
            App.Submodels.Modals.clearModals model
                |> withCmd
                    (\model ->
                        App.Server.Graph.pinCotos
                            model.clientId
                            Nothing
                            [ cotoId ]
                    )

        CotoPinned (Ok _) ->
            model |> withCmd (App.Views.Stock.renderGraph model)

        CotoPinned (Err _) ->
            model |> withoutCmd

        ConfirmUnpinCoto cotoId ->
            (App.Submodels.Modals.confirm
                (Confirmation
                    (model.i18nText I18nKeys.ConfirmUnpinCoto)
                    (UnpinCoto cotoId)
                )
                model
            )
                |> withoutCmd

        UnpinCoto cotoId ->
            { model | graph = model.graph |> App.Types.Graph.unpinCoto cotoId }
                |> withCmd
                    (\model ->
                        App.Server.Graph.unpinCoto
                            model.clientId
                            (Maybe.map (\cotonoma -> cotonoma.key) model.cotonoma)
                            cotoId
                    )

        CotoUnpinned (Ok _) ->
            model |> withCmd (App.Views.Stock.renderGraph model)

        CotoUnpinned (Err _) ->
            model |> withoutCmd

        Connected (Ok _) ->
            model |> withCmd (App.Views.Stock.renderGraph model)

        Connected (Err _) ->
            model |> withoutCmd

        DeleteConnection ( startId, endId ) ->
            { model | graph = App.Types.Graph.disconnect ( startId, endId ) model.graph }
                |> withCmd
                    (\model ->
                        App.Server.Graph.disconnect
                            model.clientId
                            (Maybe.map (\cotonoma -> cotonoma.key) model.cotonoma)
                            startId
                            endId
                    )

        ConnectionDeleted (Ok _) ->
            model |> withCmd (App.Views.Stock.renderGraph model)

        ConnectionDeleted (Err _) ->
            model |> withoutCmd

        ToggleReorderMode elementId ->
            model
                |> App.Submodels.Context.toggleReorderMode elementId
                |> withoutCmd

        SwapOrder maybeParentId index1 index2 ->
            model.graph
                |> App.Types.Graph.swapOrder maybeParentId index1 index2
                |> (\graph -> { model | graph = graph })
                |> (\model -> ( model, makeReorderCmd maybeParentId model ))

        MoveToFirst maybeParentId index ->
            model.graph
                |> App.Types.Graph.moveToFirst maybeParentId index
                |> (\graph -> { model | graph = graph })
                |> withCmd (makeReorderCmd maybeParentId)

        MoveToLast maybeParentId index ->
            model.graph
                |> App.Types.Graph.moveToLast maybeParentId index
                |> (\graph -> { model | graph = graph })
                |> withCmd (makeReorderCmd maybeParentId)

        ConnectionsReordered (Ok _) ->
            model |> withoutCmd

        ConnectionsReordered (Err _) ->
            model |> withoutCmd

        --
        -- Pushed
        --
        DeletePushed payload ->
            App.Pushed.handle Decode.string App.Pushed.handleDelete payload model
                |> addCmd (App.Views.Stock.renderGraph model)

        PostPushed payload ->
            App.Pushed.handle
                App.Server.Post.decodePost
                App.Pushed.handlePost
                payload
                model

        UpdatePushed payload ->
            (App.Pushed.handle
                App.Server.Coto.decodeCoto
                App.Pushed.handleUpdate
                payload
                model
            )
                |> addCmd (App.Views.Stock.renderGraph model)

        CotonomatizePushed payload ->
            (App.Pushed.handle
                App.Server.Cotonoma.decodeCotonoma
                App.Pushed.handleCotonomatize
                payload
                model
            )
                |> addCmd (App.Views.Stock.renderGraph model)

        ConnectPushed payload ->
            (App.Pushed.handle
                App.Pushed.decodeConnectPayloadBody
                App.Pushed.handleConnect
                payload
                model
            )
                |> addCmd (App.Views.Stock.renderGraph model)

        DisconnectPushed payload ->
            (App.Pushed.handle
                App.Pushed.decodeDisconnectPayloadBody
                App.Pushed.handleDisconnect
                payload
                model
            )
                |> addCmd (App.Views.Stock.renderGraph model)

        ReorderPushed payload ->
            App.Pushed.handle
                App.Pushed.decodeReorderPayloadBody
                App.Pushed.handleReorder
                payload
                model

        --
        -- Sub components
        --
        ViewSwitchMsg subMsg ->
            App.Views.ViewSwitch.update model subMsg model

        FlowMsg subMsg ->
            App.Views.Flow.update model subMsg model

        StockMsg subMsg ->
            App.Views.Stock.update model subMsg model

        TraversalsMsg subMsg ->
            App.Views.Traversals.update model model.graph subMsg model

        CotoSelectionMsg subMsg ->
            App.Views.CotoSelection.update model subMsg model

        CotoToolbarMsg subMsg ->
            App.Views.CotoToolbar.update model subMsg model

        SigninModalMsg subMsg ->
            App.Modals.SigninModal.update subMsg model.signinModal
                |> Tuple.mapFirst (\modal -> { model | signinModal = modal })

        EditorModalMsg subMsg ->
            App.Modals.EditorModal.update model subMsg model

        CotoMenuModalMsg subMsg ->
            model.cotoMenuModal
                |> Maybe.map (App.Modals.CotoMenuModal.update model subMsg)
                |> Maybe.map (Tuple.mapFirst (\modal -> { model | cotoMenuModal = Just modal }))
                |> Maybe.withDefault ( model, Cmd.none )

        ConnectModalMsg subMsg ->
            App.Modals.ConnectModal.update model subMsg model

        InviteModalMsg subMsg ->
            App.Modals.InviteModal.update subMsg model.inviteModal
                |> Tuple.mapFirst (\modal -> { model | inviteModal = modal })

        ImportModalMsg subMsg ->
            App.Modals.ImportModal.update model subMsg model.importModal
                |> Tuple.mapFirst (\modal -> { model | importModal = modal })

        TimelineFilterModalMsg subMsg ->
            App.Modals.TimelineFilterModal.update model subMsg model


changeLocationToHome : Model -> ( Model, Cmd Msg )
changeLocationToHome model =
    ( model, Navigation.newUrl "/" )


loadHome : Model -> ( Model, Cmd Msg )
loadHome model =
    { model
        | cotonomasLoading = True
        , subCotonomas = []
        , timeline = App.Types.Timeline.setLoading model.timeline
        , graph = App.Types.Graph.defaultGraph
        , loadingGraph = True
        , traversals = App.Types.Traversal.defaultTraversals
        , activeView = FlowView
        , navigationOpen = False
    }
        |> App.Submodels.Context.setCotonomaLoading
        |> App.Submodels.Context.clearSelection
        |> withCmd
            (\model ->
                Cmd.batch
                    [ App.Server.Post.fetchHomePosts 0 model.flowView.filter
                    , App.Server.Cotonoma.fetchCotonomas
                    , App.Server.Graph.fetchGraph Nothing
                    , App.Ports.Graph.destroyGraph ()
                    ]
            )


changeLocationToCotonoma : CotonomaKey -> Model -> ( Model, Cmd Msg )
changeLocationToCotonoma key model =
    ( model, Navigation.newUrl ("/cotonomas/" ++ key) )


loadCotonoma : CotonomaKey -> Model -> ( Model, Cmd Msg )
loadCotonoma key model =
    { model
        | cotonomasLoading = True
        , timeline = App.Types.Timeline.setLoading model.timeline
        , graph = App.Types.Graph.defaultGraph
        , loadingGraph = True
        , traversals = App.Types.Traversal.defaultTraversals
        , activeView = FlowView
        , navigationOpen = False
    }
        |> App.Submodels.Context.setCotonomaLoading
        |> App.Submodels.Context.clearSelection
        |> withCmd
            (\model ->
                Cmd.batch
                    [ App.Server.Cotonoma.fetchCotonomas
                    , App.Server.Post.fetchCotonomaPosts 0 model.flowView.filter key
                    , App.Server.Graph.fetchGraph (Just key)
                    , App.Ports.Graph.destroyGraph ()
                    ]
            )


makeReorderCmd : Maybe CotoId -> Model -> Cmd Msg
makeReorderCmd maybeParentId model =
    model.graph
        |> App.Types.Graph.getOutboundConnections maybeParentId
        |> Maybe.map (List.map (\connection -> connection.end))
        |> Maybe.map List.reverse
        |> Maybe.map
            (App.Server.Graph.reorder
                model.clientId
                (Maybe.map (\cotonoma -> cotonoma.key) model.cotonoma)
                maybeParentId
            )
        |> Maybe.withDefault Cmd.none
