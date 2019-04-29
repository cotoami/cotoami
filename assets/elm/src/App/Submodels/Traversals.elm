module App.Submodels.Traversals exposing
    ( Traversals
    , closeTraversal
    , openTraversal
    )

import App.Submodels.NarrowViewport exposing (NarrowViewport)
import App.Types.Coto exposing (CotoId)
import App.Types.Traversal


type alias Traversals a =
    NarrowViewport { a | traversals : App.Types.Traversal.Traversals }


closeTraversal : CotoId -> Traversals a -> Traversals a
closeTraversal cotoId model =
    { model | traversals = App.Types.Traversal.closeTraversal cotoId model.traversals }


openTraversal : CotoId -> Traversals a -> Traversals a
openTraversal cotoId model =
    { model | traversals = App.Types.Traversal.openTraversal cotoId model.traversals }
        |> App.Submodels.NarrowViewport.switchActiveView
            App.Submodels.NarrowViewport.TraversalsView
