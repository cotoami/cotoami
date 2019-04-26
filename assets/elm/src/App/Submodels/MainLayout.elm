module App.Submodels.MainLayout exposing
    ( closeNavOnNarrowViewport
    , toggleNavOnNarrowViewport
    )


type alias MainLayout a =
    { a
        | navOpenOnNarrowViewport : Bool
        , navEverToggled : Bool
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
