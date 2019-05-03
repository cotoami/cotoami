module App.View exposing (view)

import App.I18n.Keys as I18nKeys
import App.Messages exposing (..)
import App.Modals.AppInfoModal
import App.Modals.ConfirmModal
import App.Modals.ConnectModal
import App.Modals.ConnectionModal
import App.Modals.CotoMenuModal
import App.Modals.CotoModal
import App.Modals.EditorModal
import App.Modals.ImportModal
import App.Modals.InviteModal
import App.Modals.ProfileModal
import App.Modals.SigninModal
import App.Modals.TimelineFilterModal
import App.Model exposing (..)
import App.Submodels.LocalCotos
import App.Submodels.Modals exposing (Modal(..))
import App.Submodels.NarrowViewport exposing (ActiveView(..))
import App.Types.SearchResults
import App.Types.Session exposing (Session)
import App.Views.AppHeader
import App.Views.CotoSelection
import App.Views.Flow
import App.Views.FlowMsg
import App.Views.MainViewSwitch
import App.Views.Navigation
import App.Views.SearchResults
import App.Views.Stock
import App.Views.Traversals
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Utils.EventUtil exposing (onLinkButtonClick)
import Utils.HtmlUtil exposing (faIcon, materialIcon)


view : Model -> Html Msg
view model =
    div
        [ id "app"
        , classList
            [ ( "cotonomas-loading", model.cotonomasLoading )
            , ( App.Submodels.NarrowViewport.getActiveViewAsString model ++ "-in-narrow-viewport"
              , True
              )
            , ( "full-viewport-graph-mode", model.stockView.graphCanvasFullyOpened )
            ]
        , onClick AppClick
        ]
        [ App.Views.AppHeader.view model
        , div [ id "app-body" ]
            [ model.session
                |> Maybe.map
                    (\session ->
                        div [ id "app-layout" ]
                            [ openNavButton model
                            , navColumn model
                            , flowColumn session model
                            , graphExplorationDiv model
                            , selectionColumn model
                            , searchResultsColumn model
                            , App.Views.MainViewSwitch.view model
                            ]
                    )
                |> Maybe.withDefault Utils.HtmlUtil.none
            ]
        , App.Views.CotoSelection.statusBar model model
        , div [] (modals model)
        ]


navColumn : Model -> Html Msg
navColumn model =
    div
        [ id "main-nav"
        , classList
            ([ ( "hidden-in-narrow-viewport", not model.narrowViewport.navEverToggled )
             , ( "empty", App.Submodels.LocalCotos.isNavigationEmpty model )
             , ( "notEmpty", not (App.Submodels.LocalCotos.isNavigationEmpty model) )
             , ( "hidden", model.wideViewport.navHidden )
             ]
                ++ (if model.narrowViewport.navEverToggled then
                        [ ( "animated", True )
                        , ( "slideInDown", model.narrowViewport.navOpen )
                        , ( "slideOutUp", not model.narrowViewport.navOpen )
                        ]

                    else
                        []
                   )
            )
        ]
        [ a
            [ class "tool-button nav-toggle-in-wide-viewport hidden-in-narrow-viewport"
            , title (model.i18nText I18nKeys.Hide)
            , onLinkButtonClick ToggleNavInWideViewport
            ]
            [ materialIcon "arrow_left" Nothing ]
        , App.Views.Navigation.view model
        ]


openNavButton : Model -> Html Msg
openNavButton model =
    if model.wideViewport.navHidden then
        div
            [ id "open-nav"
            , classList
                [ ( "open-column-button", True )
                , ( "hidden-in-narrow-viewport", True )
                ]
            ]
            [ a
                [ class "tool-button"
                , onLinkButtonClick ToggleNavInWideViewport
                ]
                [ materialIcon "format_list_bulleted" Nothing ]
            ]

    else
        Utils.HtmlUtil.none


flowColumn : Session -> Model -> Html Msg
flowColumn session model =
    let
        activeInNarrowViewport =
            model.narrowViewport.activeView == FlowView
    in
    div
        [ id "main-flow"
        , classList
            [ ( "main-column", True )
            , ( "active-in-narrow-viewport", activeInNarrowViewport )
            , ( "animated", activeInNarrowViewport )
            , ( "fadeIn", activeInNarrowViewport )
            , ( "hidden", model.wideViewport.flowHidden )
            , ( "tile-view", model.flowView.view == App.Views.FlowMsg.TileView )
            ]
        ]
        [ a
            [ class "tool-button flow-toggle-in-wide-viewport hidden-in-narrow-viewport"
            , title (model.i18nText I18nKeys.Flow_HideFlow)
            , onLinkButtonClick ToggleFlowInWideViewport
            ]
            [ materialIcon "arrow_left" Nothing ]
        , App.Views.Flow.view model session model
        ]


openFlowButton : Model -> Html Msg
openFlowButton model =
    if model.wideViewport.flowHidden then
        div
            [ id "open-flow"
            , classList
                [ ( "open-column-button", True )
                , ( "hidden-in-narrow-viewport", True )
                , ( "second", model.wideViewport.navHidden )
                ]
            ]
            [ a
                [ class "tool-button"
                , title (model.i18nText I18nKeys.Flow_OpenFlow)
                , onLinkButtonClick ToggleFlowInWideViewport
                ]
                [ materialIcon "forum" Nothing ]
            ]

    else
        Utils.HtmlUtil.none


graphExplorationDiv : Model -> Html Msg
graphExplorationDiv model =
    div
        [ id "graph-exploration"
        , classList
            [ ( "active-in-narrow-viewport"
              , List.member model.narrowViewport.activeView [ StockView, TraversalsView ]
              )
            ]
        ]
        (openFlowButton model
            :: stockColumn model
            :: App.Views.Traversals.view model model
        )


stockColumn : Model -> Html Msg
stockColumn model =
    div
        [ id "main-stock"
        , classList
            [ ( "main-column", True )
            , ( "empty", List.isEmpty model.graph.rootConnections )
            , ( "active-in-narrow-viewport", model.narrowViewport.activeView == StockView )
            , ( "animated", model.narrowViewport.activeView == StockView )
            , ( "fadeIn", model.narrowViewport.activeView == StockView )
            ]
        ]
        [ App.Views.Stock.view model model.stockView ]


selectionColumn : Model -> Html Msg
selectionColumn model =
    let
        activeInNarrowViewport =
            model.narrowViewport.activeView == SelectionView
    in
    div
        [ id "main-selection"
        , classList
            [ ( "main-column", True )
            , ( "active-in-narrow-viewport", activeInNarrowViewport )
            , ( "active-in-wide-viewport", model.wideViewport.selectionOpen )
            , ( "animated", True )
            , ( "fadeIn", not (List.isEmpty model.selection) )
            , ( "empty", List.isEmpty model.selection )
            ]
        ]
        [ App.Views.CotoSelection.view model model ]


searchResultsColumn : Model -> Html Msg
searchResultsColumn model =
    let
        activeInNarrowViewport =
            model.narrowViewport.activeView == SearchResultsView
    in
    div
        [ id "main-search-results"
        , classList
            [ ( "main-column", True )
            , ( "active-in-narrow-viewport", activeInNarrowViewport )
            , ( "animated", True )
            , ( "fadeIn", App.Types.SearchResults.hasQuery model.searchResults )
            , ( "hidden"
              , not activeInNarrowViewport
                    && not (App.Types.SearchResults.hasQuery model.searchResults)
              )
            ]
        ]
        [ App.Views.SearchResults.view model model.searchResults ]


modals : Model -> List (Html Msg)
modals model =
    List.map
        (\modal ->
            case ( modal, model.session ) of
                ( ConfirmModal, _ ) ->
                    model.confirmation
                        |> Maybe.map (App.Modals.ConfirmModal.view model)
                        |> Maybe.withDefault Utils.HtmlUtil.none

                ( AppInfoModal, _ ) ->
                    App.Modals.AppInfoModal.view model

                ( SigninModal, _ ) ->
                    App.Modals.SigninModal.view model model.signinModal

                ( EditorModal, _ ) ->
                    App.Modals.EditorModal.view model model.editorModal

                ( ProfileModal, Just session ) ->
                    App.Modals.ProfileModal.view model session

                ( InviteModal, Just session ) ->
                    App.Modals.InviteModal.view model session model.inviteModal

                ( CotoMenuModal, Just session ) ->
                    model.cotoMenuModal
                        |> Maybe.map (App.Modals.CotoMenuModal.view model session)
                        |> Maybe.withDefault Utils.HtmlUtil.none

                ( CotoModal, _ ) ->
                    model.cotoModal
                        |> Maybe.map (App.Modals.CotoModal.view model)
                        |> Maybe.withDefault Utils.HtmlUtil.none

                ( ConnectModal, _ ) ->
                    App.Modals.ConnectModal.view model model.connectModal

                ( ConnectionModal, _ ) ->
                    model.connectionModal
                        |> Maybe.map (App.Modals.ConnectionModal.view model)
                        |> Maybe.withDefault Utils.HtmlUtil.none

                ( ImportModal, _ ) ->
                    model.importModal
                        |> Maybe.map App.Modals.ImportModal.view
                        |> Maybe.withDefault Utils.HtmlUtil.none

                ( TimelineFilterModal, _ ) ->
                    App.Modals.TimelineFilterModal.view model model.flowView.filter

                ( _, _ ) ->
                    Utils.HtmlUtil.none
        )
        (List.reverse model.modals)
