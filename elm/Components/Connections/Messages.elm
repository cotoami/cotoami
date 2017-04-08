module Components.Connections.Messages exposing (..)

import App.Types exposing (CotonomaKey)


type Msg
    = NoOp
    | CotoClick Int
    | CotonomaClick CotonomaKey
