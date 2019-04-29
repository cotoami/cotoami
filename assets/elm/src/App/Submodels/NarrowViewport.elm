module App.Submodels.NarrowViewport exposing
    ( ActiveView(..)
    , NarrowViewport
    , NarrowViewportState
    , closeNav
    , defaultNarrowViewportState
    , getActiveViewAsString
    , switchActiveView
    , toggleNav
    )


type ActiveView
    = FlowView
    | StockView
    | TraversalsView
    | SelectionView
    | SearchResultsView


type alias NarrowViewportState =
    { navOpen : Bool
    , navEverToggled : Bool
    , activeView : ActiveView
    }


defaultNarrowViewportState : NarrowViewportState
defaultNarrowViewportState =
    { navOpen = False
    , navEverToggled = False
    , activeView = FlowView
    }


type alias NarrowViewport a =
    { a | narrowViewport : NarrowViewportState }


switchActiveView : ActiveView -> NarrowViewport a -> NarrowViewport a
switchActiveView activeView ({ narrowViewport } as model) =
    { model | narrowViewport = { narrowViewport | activeView = activeView } }


getActiveViewAsString : NarrowViewport a -> String
getActiveViewAsString model =
    case model.narrowViewport.activeView of
        FlowView ->
            "flow"

        StockView ->
            "stock"

        TraversalsView ->
            "traversals"

        SelectionView ->
            "selection"

        SearchResultsView ->
            "search-results"


closeNav : NarrowViewport a -> NarrowViewport a
closeNav ({ narrowViewport } as model) =
    { model | narrowViewport = { narrowViewport | navOpen = False } }


toggleNav : NarrowViewport a -> NarrowViewport a
toggleNav ({ narrowViewport } as model) =
    { model
        | narrowViewport =
            { narrowViewport
                | navOpen = not narrowViewport.navOpen
                , navEverToggled = True
            }
    }
