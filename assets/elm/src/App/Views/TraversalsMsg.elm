module App.Views.TraversalsMsg exposing (Msg(..))

import App.Types.Coto exposing (CotoId)
import App.Types.Traversal exposing (Traversal)


type Msg
    = Traverse Traversal CotoId Int
    | TraverseToParent Traversal CotoId
    | CloseTraversal CotoId
    | SwitchTraversal Int
