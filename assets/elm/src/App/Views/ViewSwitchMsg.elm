module App.Views.ViewSwitchMsg exposing
    ( ActiveView(..)
    , Msg(..)
    , getActiveViewAsString
    )


type ActiveView
    = FlowView
    | StockView
    | TraversalsView
    | SelectionView
    | SearchResultsView


getActiveViewAsString : ActiveView -> String
getActiveViewAsString view =
    case view of
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


type Msg
    = SwitchView ActiveView
