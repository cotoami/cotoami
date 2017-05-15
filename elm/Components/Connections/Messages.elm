module Components.Connections.Messages exposing (..)

import App.Types exposing (CotoId, CotonomaKey)


type Msg
    = NoOp
    | CotoClick CotoId
    | CotonomaClick CotonomaKey
    | Traverse ( Int, CotoId )
    | OpenTraversal CotoId
