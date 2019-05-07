module App.Update exposing (update)

import App.Channels exposing (Payload)
import App.Commands
import App.I18n.Keys as I18nKeys
import App.LocalConfig
import App.Messages exposing (..)
import App.Modals.ConnectModal exposing (ConnectingTarget(..))
import App.Modals.ConnectionModal
import App.Modals.CotoMenuModal
import App.Modals.EditorModal
import App.Modals.ImportModal
import App.Modals.InviteModal
import App.Modals.SigninModal
import App.Modals.TimelineFilterModal
import App.Model exposing (Model)
import App.Ports.App
import App.Ports.Graph
import App.Ports.ImportFile
import App.Pushed
import App.Route exposing (Route(..))
import App.Server.Coto
import App.Server.Cotonoma
import App.Server.Graph
import App.Server.Post
import App.Server.Session
import App.Server.Watch
import App.Submodels.Context exposing (Context)
import App.Submodels.CotoSelection
import App.Submodels.LocalCotos
import App.Submodels.Modals exposing (Confirmation, Modal(..))
import App.Submodels.NarrowViewport exposing (ActiveView(..))
import App.Submodels.WideViewport
import App.Types.Amishi exposing (Presences)
import App.Types.Coto exposing (Coto, CotoId, CotonomaKey, ElementId)
import App.Types.Graph
import App.Types.Graph.Connect
import App.Types.Graph.Render
import App.Types.SearchResults
import App.Types.Timeline
import App.Types.Traversal
import App.Types.Watch
import App.Update.Modal
import App.Views.AppHeader
import App.Views.CotoSelection
import App.Views.CotoToolbar
import App.Views.Flow
import App.Views.Reorder
import App.Views.Stock
import App.Views.Traversals
import Exts.Maybe exposing (isJust)
import Http exposing (Error(..))
import Json.Decode as Decode
import Maybe
import Navigation
import Process
import Task
import Time
import Utils.Keyboard.Key
import Utils.UpdateUtil exposing (..)


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
                    && List.isEmpty model.modals
                    && not model.flowView.editorOpen
                    && not model.searchInputFocus
            then
                App.Update.Modal.openEditorModalForNew model Nothing model

            else
                model |> withoutCmd

        CloseModal ->
            App.Submodels.Modals.closeActiveModal model |> withoutCmd

        Confirm messageOnConfirm ->
            App.Submodels.Modals.closeActiveModal model
                |> withCmd (\_ -> App.Commands.sendMsg messageOnConfirm)

        AppClick ->
            { model | flowView = App.Views.Flow.openOrCloseEditor False model.flowView }
                |> withoutCmd

        OnLocationChange location ->
            App.Route.parseLocation location
                |> (\route -> ( route, { model | route = route } ))
                |> (\( route, model ) ->
                        case route of
                            HomeRoute ->
                                loadHome model

                            CotonomaRoute key ->
                                loadCotonoma key model

                            NotFoundRoute ->
                                model |> withoutCmd
                   )

        ToggleNavInNarrowViewport ->
            model
                |> App.Submodels.NarrowViewport.toggleNav
                |> withoutCmd

        ToggleNavInWideViewport ->
            model
                |> App.Submodels.WideViewport.toggleNav
                |> withoutCmd

        ToggleFlowInWideViewport ->
            model
                |> App.Submodels.WideViewport.toggleFlow
                |> withoutCmd

        SwitchViewInNarrowViewport view ->
            model
                |> App.Submodels.NarrowViewport.switchActiveView view
                |> withCmd
                    (\model ->
                        if view == StockView then
                            App.Views.Stock.resizeGraphWithDelay

                        else
                            Cmd.none
                    )

        MoveToHome ->
            ( model, Navigation.newUrl "/" )

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
                        App.Update.Modal.openSigninModal
                            (App.Server.Session.decodeAuthSettingsString response.body)
                            model
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
            { model | timeline = App.Types.Timeline.setPaginatedPosts paginatedPosts model.timeline }
                |> App.Submodels.NarrowViewport.closeNav
                |> App.Submodels.Context.setCotonoma (Just cotonoma)
                |> withCmdIf
                    (\_ -> paginatedPosts.pageIndex == 0)
                    (\model ->
                        Cmd.batch
                            [ App.Views.Flow.initScrollPos model
                            , App.Server.Cotonoma.fetchSubCotonomas model
                            , App.Server.Watch.fetchWatchlist (WatchlistOnCotonomaLoad cotonoma)
                            ]
                    )

        CotonomaPostsFetched (Err _) ->
            model |> withoutCmd

        CotonomasFetched (Ok ( global, recent )) ->
            { model
                | globalCotonomas = global
                , recentCotonomas = recent
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
                            , App.Commands.sendMsg GraphChanged
                            ]
                    )

        GraphFetched (Err _) ->
            model |> withoutCmd

        LoadSubgraph cotonomaKey ->
            App.Server.Graph.fetchSubgraph cotonomaKey model.graph
                |> Tuple.mapFirst (\graph -> { model | graph = graph })

        SubgraphFetched cotonomaKey (Ok subgraph) ->
            { model | graph = App.Types.Graph.mergeSubgraph cotonomaKey subgraph model.graph }
                |> withCmd (\model -> App.Types.Graph.Render.addSubgraph model model.graph)

        SubgraphFetched cotonomaKey (Err _) ->
            model |> withoutCmd

        SelectImportFile ->
            ( model, App.Ports.ImportFile.selectImportFile () )

        --
        -- Search
        --
        SearchInputFocusChanged focus ->
            { model | searchInputFocus = focus } |> withoutCmd

        SearchInput query ->
            { model | searchResults = App.Types.SearchResults.setQuery query model.searchResults }
                |> withoutCmd

        Search ->
            { model | searchResults = App.Types.SearchResults.setLoading model.searchResults }
                |> withCmdIf
                    (\model -> App.Types.SearchResults.hasQuery model.searchResults)
                    (\model -> App.Server.Post.search model.searchResults.query)

        SearchResultsFetched (Ok posts) ->
            { model
                | searchResults =
                    App.Types.SearchResults.setPosts posts model.searchResults
            }
                |> withoutCmd

        SearchResultsFetched (Err _) ->
            model |> withoutCmd

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

        SelectCoto coto ->
            model
                |> App.Submodels.CotoSelection.toggleSelection coto
                |> App.Submodels.WideViewport.closeSelectionIfEmpty model
                |> withoutCmd

        OpenTraversal cotoId ->
            let
                ( graph, fetchSubgraph ) =
                    App.Server.Graph.fetchSubgraphIfCotonoma
                        (App.Submodels.LocalCotos.getCoto cotoId model)
                        model.graph
            in
            { model | graph = graph }
                |> App.Model.openTraversal cotoId
                |> App.Submodels.Modals.clearModals
                |> withCmd
                    (\model ->
                        Cmd.batch
                            [ App.Commands.scrollGraphExplorationToRight NoOp
                            , App.Commands.scrollTraversalsPaginationToRight NoOp
                            , fetchSubgraph
                            , App.Views.Stock.resizeGraphWithDelay
                            ]
                    )

        CotonomaClick key ->
            changeLocationToCotonoma key model

        ToggleCotoContent elementId ->
            model
                |> App.Submodels.Context.toggleContent elementId
                |> withoutCmd

        ConfirmDeleteCoto cotoId ->
            App.Submodels.Modals.confirm
                (Confirmation
                    (model.i18nText I18nKeys.ConfirmDeleteCoto)
                    (DeleteCotoInServerSide cotoId)
                )
                model
                |> withoutCmd

        DeleteCotoInServerSide cotoId ->
            { model | timeline = App.Types.Timeline.setBeingDeleted cotoId model.timeline }
                |> App.Submodels.Modals.clearModals
                |> withCmd
                    (\model ->
                        Cmd.batch
                            [ App.Server.Coto.deleteCoto model.clientId cotoId
                            , Process.sleep (1 * Time.second)
                                |> Task.andThen (\_ -> Task.succeed ())
                                |> Task.perform (\_ -> DeleteCotoInClientSide cotoId)
                            ]
                    )

        DeleteCotoInClientSide cotoId ->
            model
                |> App.Model.deleteCoto cotoId
                |> withCmd (\_ -> App.Commands.sendMsg GraphChanged)

        CotoDeleted (Ok _) ->
            model |> withCmd App.Server.Cotonoma.refreshCotonomaList

        CotoDeleted (Err error) ->
            model |> withoutCmd

        CotoUpdated (Ok coto) ->
            model
                |> App.Submodels.LocalCotos.updateCoto coto
                |> App.Submodels.LocalCotos.updateCotonomaMaybe coto.postedIn
                |> App.Submodels.Modals.clearModals
                |> withCmdIf
                    (\_ -> isJust coto.asCotonoma)
                    App.Server.Cotonoma.refreshCotonomaList
                |> addCmd (\_ -> App.Commands.sendMsg GraphChanged)

        CotoUpdated (Err error) ->
            model.editorModal
                |> App.Modals.EditorModal.setCotoSaveError error
                |> (\editorModal -> { model | editorModal = editorModal })
                |> withoutCmd

        ConfirmCotonomatize coto ->
            if String.length coto.content <= App.Types.Coto.cotonomaNameMaxlength then
                App.Submodels.Modals.confirm
                    (Confirmation
                        (model.i18nText (I18nKeys.ConfirmCotonomatize coto.content))
                        (Cotonomatize coto.id)
                    )
                    model
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
                |> withCmd App.Server.Cotonoma.refreshCotonomaList
                |> addCmd (\_ -> App.Commands.sendMsg GraphChanged)

        Cotonomatized (Err error) ->
            model.cotoMenuModal
                |> Maybe.map (\cotoMenuModal -> App.Modals.EditorModal.modelForEdit cotoMenuModal.coto)
                |> Maybe.map (App.Modals.EditorModal.setCotoSaveError error)
                |> Maybe.map (\editorModal -> { model | editorModal = editorModal })
                |> Maybe.map (App.Submodels.Modals.openModal EditorModal)
                |> Maybe.withDefault model
                |> withoutCmd

        PinCoto cotoId ->
            Maybe.map2
                (\session coto ->
                    { model
                        | graph =
                            App.Types.Graph.Connect.pin
                                session.amishi.id
                                coto
                                Nothing
                                model.graph
                    }
                        |> withCmd
                            (\model ->
                                Cmd.batch
                                    [ App.Server.Graph.pinCotos
                                        model.clientId
                                        (Maybe.map .key model.cotonoma)
                                        [ cotoId ]
                                    , App.Commands.scrollPinnedCotosToBottom (\_ -> NoOp)
                                    ]
                            )
                )
                model.session
                (App.Submodels.LocalCotos.getCoto cotoId model)
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
            model |> withCmd (\_ -> App.Commands.sendMsg GraphChanged)

        CotoPinned (Err _) ->
            model |> withoutCmd

        ConfirmUnpinCoto cotoId ->
            App.Submodels.Modals.confirm
                (Confirmation
                    (model.i18nText I18nKeys.ConfirmUnpinCoto)
                    (UnpinCoto cotoId)
                )
                model
                |> withoutCmd

        UnpinCoto cotoId ->
            { model | graph = model.graph |> App.Types.Graph.Connect.unpin cotoId }
                |> withCmd
                    (\model ->
                        App.Server.Graph.unpinCoto
                            model.clientId
                            (Maybe.map .key model.cotonoma)
                            cotoId
                    )

        CotoUnpinned (Ok _) ->
            model
                |> App.Submodels.Modals.closeModal ConnectionModal
                |> withCmd (\_ -> App.Commands.sendMsg GraphChanged)

        CotoUnpinned (Err _) ->
            model |> withoutCmd

        Connected (Ok _) ->
            model |> withCmd (\_ -> App.Commands.sendMsg GraphChanged)

        Connected (Err _) ->
            model |> withoutCmd

        DeleteConnection ( startId, endId ) ->
            { model | graph = App.Types.Graph.Connect.disconnect ( startId, endId ) model.graph }
                |> withCmd (\model -> App.Server.Graph.disconnect model.clientId startId endId)

        ConnectionDeleted (Ok _) ->
            model
                |> App.Submodels.Modals.closeModal ConnectionModal
                |> withCmd (\_ -> App.Commands.sendMsg GraphChanged)

        ConnectionDeleted (Err _) ->
            model |> withoutCmd

        SetReorderMode reordering ->
            { model | reordering = Just reordering } |> withoutCmd

        CloseReorderMode ->
            { model | reordering = Nothing } |> withoutCmd

        Watch cotonomaKey ->
            { model | watchlistLoading = True }
                |> withCmd (\model -> App.Server.Watch.watch WatchlistUpdated model.clientId cotonomaKey)

        Unwatch cotonomaKey ->
            { model | watchlistLoading = True }
                |> withCmd (\model -> App.Server.Watch.unwatch WatchlistUpdated model.clientId cotonomaKey)

        WatchlistUpdated (Ok watchlist) ->
            { model | watchlist = watchlist, watchlistLoading = False }
                |> withCmd App.Ports.App.updateUnreadStateInTitle

        WatchlistUpdated (Err _) ->
            model |> withoutCmd

        WatchlistOnCotonomaLoad cotonoma (Ok watchlist) ->
            { model
                | watchlist = watchlist
                , watchlistLoading = False
                , watchStateOnCotonomaLoad =
                    App.Types.Watch.findWatchByCotonomaId cotonoma.id watchlist
            }
                |> withCmd App.Ports.App.updateUnreadStateInTitle

        WatchlistOnCotonomaLoad cotonoma (Err _) ->
            model |> withoutCmd

        WatchTimestampUpdated _ ->
            { model | watchUpdating = False }
                |> withCmd App.Ports.App.updateUnreadStateInTitle

        GraphChanged ->
            model |> withCmd (App.Views.Stock.renderGraph model)

        --
        -- Pushed
        --
        PostPushed payload ->
            App.Pushed.handle
                App.Server.Post.decodePost
                App.Pushed.handlePost
                payload
                model

        DeletePushed payload ->
            App.Pushed.handle Decode.string App.Pushed.handleDelete payload model

        CotoUpdatePushed payload ->
            App.Pushed.handle
                App.Server.Coto.decodeCoto
                App.Pushed.handleCotoUpdate
                payload
                model

        CotonomatizePushed payload ->
            App.Pushed.handle
                App.Server.Cotonoma.decodeCotonoma
                App.Pushed.handleCotonomatize
                payload
                model

        CotonomaUpdatePushed payload ->
            App.Pushed.handle
                App.Server.Cotonoma.decodeCotonoma
                App.Pushed.handleCotonomaUpdate
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

        ConnectionUpdatePushed payload ->
            App.Pushed.handle
                App.Pushed.decodeConnectionUpdatePayloadBody
                App.Pushed.handleConnectionUpdate
                payload
                model

        ReorderPushed payload ->
            App.Pushed.handle
                App.Pushed.decodeReorderPayloadBody
                App.Pushed.handleReorder
                payload
                model

        --
        -- Open modal
        --
        ClearModals ->
            App.Submodels.Modals.clearModals model
                |> withoutCmd

        CloseActiveModal ->
            App.Submodels.Modals.closeActiveModal model
                |> withoutCmd

        OpenConfirmModal message msgOnConfirm ->
            App.Submodels.Modals.confirm (Confirmation message msgOnConfirm) model
                |> withoutCmd

        OpenAppInfoModal ->
            App.Submodels.Modals.openModal AppInfoModal model
                |> withoutCmd

        OpenSigninModal ->
            App.Update.Modal.openSigninModal model.signinModal.authSettings model
                |> withoutCmd

        OpenProfileModal ->
            App.Submodels.Modals.openModal ProfileModal model
                |> withoutCmd

        OpenCotoMenuModal coto ->
            App.Update.Modal.openCotoMenuModal coto model

        OpenNewEditorModal ->
            App.Update.Modal.openEditorModalForNew model Nothing model

        OpenNewEditorModalWithSourceCoto coto ->
            App.Update.Modal.openEditorModalForNew model (Just coto) model

        OpenEditorModal coto ->
            App.Update.Modal.openEditorModalForEdit coto model

        OpenCotoModal coto ->
            App.Update.Modal.openCotoModal coto model
                |> withoutCmd

        OpenImportModal importFile ->
            App.Update.Modal.openImportModal importFile model
                |> withoutCmd

        OpenTimelineFilterModal ->
            model
                |> App.Submodels.Modals.openModal TimelineFilterModal
                |> withoutCmd

        OpenConnectModalByCoto coto ->
            App.Update.Modal.openConnectModalByCoto coto model

        OpenConnectModalByNewPost content onPosted ->
            App.Update.Modal.openConnectModalByNewPost onPosted content model

        OpenConnectionModal connection startCoto endCoto ->
            App.Update.Modal.openConnectionModal model connection startCoto endCoto model

        OpenInviteModal ->
            App.Update.Modal.openInviteModal model

        --
        -- Sub components
        --
        AppHeaderMsg subMsg ->
            App.Views.AppHeader.update model subMsg model

        FlowMsg subMsg ->
            App.Views.Flow.update model subMsg model

        StockMsg subMsg ->
            App.Views.Stock.update model subMsg model

        TraversalsMsg subMsg ->
            App.Views.Traversals.update model subMsg model

        CotoSelectionMsg subMsg ->
            App.Views.CotoSelection.update model subMsg model

        CotoToolbarMsg subMsg ->
            App.Views.CotoToolbar.update model subMsg model

        ReorderMsg subMsg ->
            App.Views.Reorder.update model subMsg model

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

        ConnectionModalMsg subMsg ->
            model.connectionModal
                |> Maybe.map (\modal -> ( modal, model.graph ))
                |> Maybe.map (App.Modals.ConnectionModal.update model subMsg)
                |> Maybe.map
                    (\( ( modal, graph ), cmd ) ->
                        ( { model | connectionModal = Just modal, graph = graph }, cmd )
                    )
                |> Maybe.withDefault ( model, Cmd.none )

        InviteModalMsg subMsg ->
            App.Modals.InviteModal.update subMsg model.inviteModal
                |> Tuple.mapFirst (\modal -> { model | inviteModal = modal })

        ImportModalMsg subMsg ->
            model.importModal
                |> Maybe.map (App.Modals.ImportModal.update model subMsg)
                |> Maybe.map (Tuple.mapFirst (\modal -> { model | importModal = Just modal }))
                |> Maybe.withDefault ( model, Cmd.none )

        TimelineFilterModalMsg subMsg ->
            App.Modals.TimelineFilterModal.update model subMsg model


loadHome : Model -> ( Model, Cmd Msg )
loadHome model =
    { model
        | cotonomasLoading = True
        , subCotonomas = []
        , timeline = App.Types.Timeline.setInitializing model.timeline
        , graph = App.Types.Graph.defaultGraph
        , loadingGraph = True
        , traversals = App.Types.Traversal.defaultTraversals
        , watchlistLoading = True
    }
        |> App.Submodels.Context.setCotonomaLoading
        |> App.Submodels.NarrowViewport.closeNav
        |> App.Submodels.NarrowViewport.switchActiveView FlowView
        |> withCmd
            (\model ->
                Cmd.batch
                    [ App.Server.Post.fetchHomePosts 0 model.flowView.filter
                    , App.Server.Cotonoma.fetchCotonomas
                    , App.Server.Graph.fetchGraph Nothing
                    , App.Ports.Graph.destroyGraph ()
                    , App.Server.Watch.fetchWatchlist WatchlistUpdated
                    ]
            )


changeLocationToCotonoma : CotonomaKey -> Model -> ( Model, Cmd Msg )
changeLocationToCotonoma key model =
    ( model, Navigation.newUrl ("/cotonomas/" ++ key) )


loadCotonoma : CotonomaKey -> Model -> ( Model, Cmd Msg )
loadCotonoma key model =
    { model
        | cotonomasLoading = True
        , timeline = App.Types.Timeline.setInitializing model.timeline
        , graph = App.Types.Graph.defaultGraph
        , loadingGraph = True
        , traversals = App.Types.Traversal.defaultTraversals
        , watchlistLoading = True
    }
        |> App.Submodels.Context.setCotonomaLoading
        |> App.Submodels.NarrowViewport.closeNav
        |> App.Submodels.NarrowViewport.switchActiveView FlowView
        |> withCmd
            (\model ->
                Cmd.batch
                    [ App.Server.Cotonoma.fetchCotonomas
                    , App.Server.Post.fetchCotonomaPosts 0 model.flowView.filter key
                    , App.Server.Graph.fetchGraph (Just key)
                    , App.Ports.Graph.destroyGraph ()
                    ]
            )
