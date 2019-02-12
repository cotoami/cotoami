module App.Views.StockMsg exposing (Msg(..), StockView(..))

import App.Types.Coto exposing (CotoId)


type StockView
    = DocumentView
    | GraphView


type Msg
    = SwitchView StockView
    | RenderGraph
    | ResizeGraph
    | ToggleGraphCanvasSize
    | GraphNodeClicked CotoId
