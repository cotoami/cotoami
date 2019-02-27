module App.Types.TimelineFilter exposing
    ( TimelineFilter
    , defaultTimelineFilter
    )


type alias TimelineFilter =
    { excludePinnedGraph : Bool
    , excludePostsInCotonoma : Bool
    }


defaultTimelineFilter : TimelineFilter
defaultTimelineFilter =
    { excludePinnedGraph = False
    , excludePostsInCotonoma = False
    }
