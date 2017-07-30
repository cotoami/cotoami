module Components.Traversals.Messages exposing (..)

import App.Types.Coto exposing (Coto, CotoId, CotonomaKey)
import Components.Traversals.Model exposing (Traverse)


type Msg
    = NoOp
    | CotoClick CotoId
    | CotoMouseEnter CotoId
    | CotoMouseLeave CotoId
    | OpenCoto Coto
    | SelectCoto CotoId
    | CotonomaClick CotonomaKey
    | TraverseClick Traverse
    | OpenTraversal CotoId
    | CloseTraversal CotoId
    | ChangePage Int
    | ConfirmDeleteConnection ( CotoId, CotoId )
    | DeleteConnection ( CotoId, CotoId )
