module App.Submodels.MainLayout exposing
    ( NarrowViewport
    , WideViewport
    , closeNavOnNarrowViewport
    , defaultNarrowViewport
    , defaultWideViewport
    , toggleFlowOnWideViewport
    , toggleNavOnNarrowViewport
    )


type alias MainLayout a =
    { a
        | narrowViewport : NarrowViewport
        , wideViewport : WideViewport
    }


type alias NarrowViewport =
    { navOpen : Bool
    , navEverToggled : Bool
    }


defaultNarrowViewport : NarrowViewport
defaultNarrowViewport =
    { navOpen = False
    , navEverToggled = False
    }


type alias WideViewport =
    { flowHidden : Bool
    }


defaultWideViewport : WideViewport
defaultWideViewport =
    { flowHidden = False
    }


closeNavOnNarrowViewport : MainLayout a -> MainLayout a
closeNavOnNarrowViewport ({ narrowViewport } as model) =
    { model | narrowViewport = { narrowViewport | navOpen = False } }


toggleNavOnNarrowViewport : MainLayout a -> MainLayout a
toggleNavOnNarrowViewport ({ narrowViewport } as model) =
    { model
        | narrowViewport =
            { narrowViewport
                | navOpen = not narrowViewport.navOpen
                , navEverToggled = True
            }
    }


toggleFlowOnWideViewport : MainLayout a -> MainLayout a
toggleFlowOnWideViewport ({ wideViewport } as model) =
    { model
        | wideViewport =
            { wideViewport | flowHidden = not wideViewport.flowHidden }
    }
