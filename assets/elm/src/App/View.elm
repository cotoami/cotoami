module App.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Utils.HtmlUtil exposing (faIcon, materialIcon)
import Utils.EventUtil exposing (onLinkButtonClick)
import App.I18n.Keys as I18nKeys
import App.Types.Session exposing (Session)
import App.Types.SearchResults
import App.Messages exposing (..)
import App.Model exposing (..)
import App.Submodels.LocalCotos
import App.Submodels.Modals exposing (Modal(..))
import App.Views.AppHeader
import App.Views.Navigation
import App.Views.ViewSwitch
import App.Views.ViewSwitchMsg exposing (ActiveView(..))
import App.Views.Flow
import App.Views.FlowMsg
import App.Views.Stock
import App.Views.Traversals
import App.Views.CotoSelection
import App.Views.SearchResults
import App.Modals.ConnectModal
import App.Modals.ProfileModal
import App.Modals.InviteModal
import App.Modals.CotoMenuModal
import App.Modals.CotoModal
import App.Modals.SigninModal
import App.Modals.EditorModal
import App.Modals.ConfirmModal
import App.Modals.ImportModal
import App.Modals.TimelineFilterModal


view : Model -> Html Msg
view model =
    div
        [ id "app"
        , classList
            [ ( "cotonomas-loading", model.cotonomasLoading )
            , ( (App.Views.ViewSwitchMsg.getActiveViewAsString model.activeView)
                    ++ "-view-on-mobile"
              , True
              )
            ]
        , onClick AppClick
        ]
        [ App.Views.AppHeader.view model
        , div [ id "app-body" ]
            [ div [ id "app-layout" ]
                [ navColumn model
                , flowColumn model
                , graphExplorationDiv model
                , selectionColumn model
                , searchResultsColumn model
                , App.Views.ViewSwitch.view model
                ]
            ]
        , App.Views.CotoSelection.statusBar model model
        , div [] (modals model)
        ]


navColumn : Model -> Html Msg
navColumn model =
    div
        [ id "main-nav"
        , classList
            [ ( "neverToggled", not model.navigationToggled )
            , ( "empty", App.Submodels.LocalCotos.isNavigationEmpty model )
            , ( "notEmpty", not (App.Submodels.LocalCotos.isNavigationEmpty model) )
            , ( "animated", model.navigationToggled )
            , ( "slideInDown", model.navigationToggled && model.navigationOpen )
            , ( "slideOutUp", model.navigationToggled && not model.navigationOpen )
            ]
        ]
        (App.Views.Navigation.view model)


graphExplorationDiv : Model -> Html Msg
graphExplorationDiv model =
    div
        [ id "graph-exploration"
        , classList
            [ ( "active-in-narrow-viewport"
              , List.member model.activeView [ StockView, TraversalsView ]
              )
            , ( "flow-hidden", model.flowView.hidden )
            ]
        ]
        (openFlowButton model
            :: stockColumn model
            :: (App.Views.Traversals.view model model)
        )


openFlowButton : Model -> Html Msg
openFlowButton model =
    if model.flowView.hidden then
        div [ id "open-flow" ]
            [ a
                [ class "tool-button flow-toggle"
                , title (model.i18nText I18nKeys.Flow_OpenFlow)
                , onLinkButtonClick (FlowMsg App.Views.FlowMsg.ToggleFlow)
                ]
                [ materialIcon "chat" Nothing ]
            ]
    else
        Utils.HtmlUtil.none


flowColumn : Model -> Html Msg
flowColumn model =
    model.session
        |> Maybe.map
            (\session ->
                if model.flowView.hidden then
                    flowDiv
                        session
                        [ ( "main-column", True )
                        , ( "hidden", True )
                        ]
                        model
                else
                    let
                        active =
                            model.activeView == FlowView
                    in
                        flowDiv
                            session
                            [ ( "main-column", True )
                            , ( "active-in-narrow-viewport", active )
                            , ( "animated", active )
                            , ( "fadeIn", active )
                            ]
                            model
            )
        |> Maybe.withDefault Utils.HtmlUtil.none


flowDiv : Session -> List ( String, Bool ) -> Model -> Html Msg
flowDiv session classes model =
    div
        [ id "main-flow"
        , classList classes
        ]
        [ App.Views.Flow.view model session model ]


stockColumn : Model -> Html Msg
stockColumn model =
    div
        [ id "main-stock"
        , classList
            [ ( "main-column", True )
            , ( "empty", List.isEmpty model.graph.rootConnections )
            , ( "active-in-narrow-viewport", model.activeView == StockView )
            , ( "animated", model.activeView == StockView )
            , ( "fadeIn", model.activeView == StockView )
            ]
        ]
        [ App.Views.Stock.view model model
        ]


selectionColumn : Model -> Html Msg
selectionColumn model =
    div
        [ id "main-selection"
        , classList
            [ ( "main-column", True )
            , ( "active-in-narrow-viewport", model.activeView == SelectionView )
            , ( "animated", True )
            , ( "fadeIn", not (List.isEmpty model.selection) )
            , ( "empty", List.isEmpty model.selection )
            , ( "hidden", not model.selectionView.columnOpen )
            ]
        ]
        [ App.Views.CotoSelection.view model model
        ]


searchResultsColumn : Model -> Html Msg
searchResultsColumn model =
    div
        [ id "main-search-results"
        , classList
            [ ( "main-column", True )
            , ( "active-in-narrow-viewport", model.activeView == SearchResultsView )
            , ( "animated", True )
            , ( "fadeIn", App.Types.SearchResults.hasQuery model.searchResults )
            , ( "hidden", not (App.Types.SearchResults.hasQuery model.searchResults) )
            ]
        ]
        [ App.Views.SearchResults.view model model.graph model.searchResults
        ]


modals : Model -> List (Html Msg)
modals model =
    List.map
        (\modal ->
            case modal of
                ConfirmModal ->
                    App.Modals.ConfirmModal.view model model.confirmation.message

                SigninModal ->
                    App.Modals.SigninModal.view model model.signinModal

                EditorModal ->
                    App.Modals.EditorModal.view model model.editorModal

                ProfileModal ->
                    App.Modals.ProfileModal.view model

                InviteModal ->
                    App.Modals.InviteModal.view model model.inviteModal

                CotoMenuModal ->
                    App.Modals.CotoMenuModal.view model model.graph model.cotoMenuModal

                CotoModal ->
                    App.Modals.CotoModal.view model model.cotoModal

                ConnectModal ->
                    App.Modals.ConnectModal.view
                        model
                        (App.Submodels.LocalCotos.getSelectedCotos model model)
                        model.connectModal

                ImportModal ->
                    App.Modals.ImportModal.view model.importModal

                TimelineFilterModal ->
                    App.Modals.TimelineFilterModal.view model model.flowView.filter
        )
        (List.reverse model.modals)
