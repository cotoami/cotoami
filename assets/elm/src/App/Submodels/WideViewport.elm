module App.Submodels.WideViewport exposing
    ( WideViewport
    , WideViewportState
    , defaultWideViewportState
    , toggleFlow
    , toggleNav
    )


type alias WideViewportState =
    { navHidden : Bool
    , flowHidden : Bool
    }


defaultWideViewportState : WideViewportState
defaultWideViewportState =
    { navHidden = False
    , flowHidden = False
    }


type alias WideViewport a =
    { a | wideViewport : WideViewportState }


toggleNav : WideViewport a -> WideViewport a
toggleNav ({ wideViewport } as model) =
    { model
        | wideViewport =
            { wideViewport | navHidden = not wideViewport.navHidden }
    }


toggleFlow : WideViewport a -> WideViewport a
toggleFlow ({ wideViewport } as model) =
    { model
        | wideViewport =
            { wideViewport | flowHidden = not wideViewport.flowHidden }
    }
