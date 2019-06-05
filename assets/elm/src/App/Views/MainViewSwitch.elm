module App.Views.MainViewSwitch exposing (view)

import App.Messages as AppMsg exposing (..)
import App.Submodels.Context exposing (Context)
import App.Submodels.CotoSelection
import App.Submodels.LocalCotos exposing (LocalCotos)
import App.Submodels.NarrowViewport exposing (ActiveView(..), NarrowViewport)
import App.Types.Traversal exposing (Traversals)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Utils.HtmlUtil exposing (faIcon)


type alias ViewModel model =
    Context (NarrowViewport (LocalCotos { model | traversals : Traversals }))


view : ViewModel model -> Html AppMsg.Msg
view model =
    div
        [ id "main-view-switch" ]
        [ viewSwitchDiv
            "switch-to-flow"
            "comments"
            "Switch to flow view"
            (model.narrowViewport.activeView == FlowView)
            False
            (SwitchViewInNarrowViewport FlowView)
        , viewSwitchDiv
            "switch-to-stock"
            "thumb-tack"
            "Switch to stock view"
            (model.narrowViewport.activeView == StockView)
            (App.Submodels.LocalCotos.isStockEmpty model)
            (SwitchViewInNarrowViewport StockView)
        , viewSwitchDiv
            "switch-to-traversals"
            "sitemap"
            "Switch to traversals"
            (model.narrowViewport.activeView == TraversalsView)
            (App.Types.Traversal.isEmpty model.traversals)
            (SwitchViewInNarrowViewport TraversalsView)
        , viewSwitchDiv
            "switch-to-selection"
            "check-square-o"
            "Switch to coto selection"
            (model.narrowViewport.activeView == SelectionView)
            (not (App.Submodels.CotoSelection.anySelection model))
            (SwitchViewInNarrowViewport SelectionView)
        , viewSwitchDiv
            "switch-to-search"
            "search"
            "Switch to search cotos"
            (model.narrowViewport.activeView == SearchResultsView)
            False
            (SwitchViewInNarrowViewport SearchResultsView)
        ]


viewSwitchDiv : String -> String -> String -> Bool -> Bool -> AppMsg.Msg -> Html AppMsg.Msg
viewSwitchDiv divId iconName buttonTitle selected empty onClickMsg =
    div
        [ id divId
        , classList
            [ ( "switch-button", True )
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
