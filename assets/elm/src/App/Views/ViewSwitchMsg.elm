module App.Views.ViewSwitchMsg
    exposing
        ( ActiveView(..)
        , getActiveViewAsString
        , Msg(..)
        )


type ActiveView
    = TimelineView
    | PinnedView
    | TraversalsView
    | SelectionView
    | SearchResultsView


getActiveViewAsString : ActiveView -> String
getActiveViewAsString view =
    case view of
        TimelineView ->
            "timeline"

        PinnedView ->
            "pinned"

        TraversalsView ->
            "traversals"

        SelectionView ->
            "selection"

        SearchResultsView ->
            "search-results"


type Msg
    = SwitchView ActiveView
