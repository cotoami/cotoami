module App.Views.StockMsg exposing (StockView(..), Msg(..))


type StockView
    = DocumentView
    | GraphView


type Msg
    = SwitchView StockView
    | RenderGraph
    | ResizeGraph
