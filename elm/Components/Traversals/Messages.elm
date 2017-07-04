module Components.Traversals.Messages exposing (..)

import App.Types exposing (Coto, CotoId, CotonomaKey)
import Components.Traversals.Model exposing (Traverse)


type Msg
    = NoOp
    | CotoClick CotoId
    | OpenCoto Coto
    | CotonomaClick CotonomaKey
    | TraverseClick Traverse
    | OpenTraversal CotoId
    | CloseTraversal CotoId
    | ChangePage Int
    | ConfirmDeleteConnection ( CotoId, CotoId )
    | DeleteConnection ( CotoId, CotoId )
