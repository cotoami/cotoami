module Components.Traversals.Messages exposing (..)

import App.Types exposing (CotoId, CotonomaKey)
import Components.Traversals.Model exposing (Traverse)


type Msg
    = NoOp
    | CotoClick CotoId
    | CotonomaClick CotonomaKey
    | TraverseClick Traverse
    | OpenTraversal CotoId
