module Components.Connections.Messages exposing (..)

import App.Types exposing (CotoId, CotonomaKey)
import App.Graph exposing (Traverse)


type Msg
    = NoOp
    | CotoClick CotoId
    | CotonomaClick CotonomaKey
    | TraverseClick Traverse
    | OpenTraversal CotoId
