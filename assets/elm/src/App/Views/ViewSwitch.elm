module App.Views.ViewSwitch
    exposing
        ( update
        , view
        )

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Utils.UpdateUtil exposing (..)
import Utils.HtmlUtil exposing (faIcon)
import App.Types.Coto exposing (CotoSelection)
import App.Types.Traversal exposing (Traversals)
import App.Submodels.Context exposing (Context)
import App.Submodels.LocalCotos exposing (LocalCotos)
import App.Messages as AppMsg exposing (..)
import App.Views.ViewSwitchMsg as ViewSwitchMsg exposing (Msg(..), ActiveView(..))
import App.Views.Stock


type alias UpdateModel model =
    { model
        | activeView : ActiveView
    }


update : Context context -> ViewSwitchMsg.Msg -> UpdateModel model -> ( UpdateModel model, Cmd AppMsg.Msg )
update context msg model =
    case msg of
        SwitchView view ->
            { model | activeView = view }
                |> withCmd
                    (\model ->
                        if view == StockView then
                            App.Views.Stock.resizeGraphWithDelay
                        else
                            Cmd.none
                    )


type alias ViewModel model =
    LocalCotos
        { model
            | activeView : ActiveView
            , traversals : Traversals
            , selection : CotoSelection
        }


view : ViewModel model -> Html AppMsg.Msg
view model =
    div
        [ id "view-switch-container" ]
        [ viewSwitchDiv
            "switch-to-flow"
            "comments"
            "Switch to flow view"
            (model.activeView == FlowView)
            False
            (AppMsg.ViewSwitchMsg (SwitchView FlowView))
        , viewSwitchDiv
            "switch-to-stock"
            "thumb-tack"
            "Switch to stock view"
            (model.activeView == StockView)
            (App.Submodels.LocalCotos.isStockEmpty model)
            (AppMsg.ViewSwitchMsg (SwitchView StockView))
        , viewSwitchDiv
            "switch-to-traversals"
            "sitemap"
            "Switch to traversals"
            (model.activeView == TraversalsView)
            (App.Types.Traversal.isEmpty model.traversals)
            (AppMsg.ViewSwitchMsg (SwitchView TraversalsView))
        , viewSwitchDiv
            "switch-to-selection"
            "check-square-o"
            "Switch to coto selection"
            (model.activeView == SelectionView)
            (List.isEmpty model.selection)
            (AppMsg.ViewSwitchMsg (SwitchView SelectionView))
        , viewSwitchDiv
            "switch-to-search"
            "search"
            "Switch to search cotos"
            (model.activeView == SearchResultsView)
            False
            (AppMsg.ViewSwitchMsg (SwitchView SearchResultsView))
        ]


viewSwitchDiv : String -> String -> String -> Bool -> Bool -> AppMsg.Msg -> Html AppMsg.Msg
viewSwitchDiv divId iconName buttonTitle selected empty onClickMsg =
    div
        [ id divId
        , classList
            [ ( "view-switch", True )
            , ( "selected", selected )
            , ( "empty", empty )
            ]
        ]
        [ if selected || empty then
            span
                [ class "tool-button" ]
                [ faIcon iconName Nothing ]
          else
            a
                [ class "tool-button"
                , title buttonTitle
                , onClick onClickMsg
                ]
                [ faIcon iconName Nothing ]
        ]
