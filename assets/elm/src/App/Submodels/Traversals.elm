module App.Submodels.Traversals exposing
    ( Traversals
    , closeTraversal
    , openTraversal
    )

import App.Types.Coto exposing (CotoId)
import App.Types.Traversal
import App.Views.ViewSwitchMsg exposing (ActiveView(..))


type alias Traversals a =
    { a
        | traversals : App.Types.Traversal.Traversals
        , activeView : ActiveView
    }


closeTraversal : CotoId -> Traversals a -> Traversals a
closeTraversal cotoId model =
    { model | traversals = App.Types.Traversal.closeTraversal cotoId model.traversals }


openTraversal : CotoId -> Traversals a -> Traversals a
openTraversal cotoId model =
    { model
        | traversals = App.Types.Traversal.openTraversal cotoId model.traversals
        , activeView = TraversalsView
    }
