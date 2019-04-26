module App.Submodels.MainLayout exposing
    ( closeNavOnNarrowViewport
    , toggleFlowOnWideViewport
    , toggleNavOnNarrowViewport
    )


type alias MainLayout a =
    { a
        | navOpenOnNarrowViewport : Bool
        , navEverToggled : Bool
        , flowHiddenOnWideViewport : Bool
    }


closeNavOnNarrowViewport : MainLayout a -> MainLayout a
closeNavOnNarrowViewport model =
    { model | navOpenOnNarrowViewport = False }


toggleNavOnNarrowViewport : MainLayout a -> MainLayout a
toggleNavOnNarrowViewport model =
    { model
        | navOpenOnNarrowViewport = not model.navOpenOnNarrowViewport
        , navEverToggled = True
    }


toggleFlowOnWideViewport : MainLayout a -> MainLayout a
toggleFlowOnWideViewport model =
    { model | flowHiddenOnWideViewport = not model.flowHiddenOnWideViewport }
