module App.Submodels.WideViewport exposing
    ( WideViewport
    , WideViewportState
    , defaultWideViewportState
    , toggleFlow
    )


type alias WideViewportState =
    { flowHidden : Bool
    }


defaultWideViewportState : WideViewportState
defaultWideViewportState =
    { flowHidden = False
    }


type alias WideViewport a =
    { a | wideViewport : WideViewportState }


toggleFlow : WideViewport a -> WideViewport a
toggleFlow ({ wideViewport } as model) =
    { model
        | wideViewport =
            { wideViewport | flowHidden = not wideViewport.flowHidden }
    }
