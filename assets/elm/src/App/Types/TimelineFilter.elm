module App.Types.TimelineFilter
    exposing
        ( TimelineFilter
        , defaultTimelineFilter
        , decodeTimelineFilter
        , encodeTimelineFilter
        )

import Json.Decode as Decode
import Json.Encode as Encode


type alias TimelineFilter =
    { excludePinnedGraph : Bool
    , excludePostsInCotonoma : Bool
    }


defaultTimelineFilter : TimelineFilter
defaultTimelineFilter =
    { excludePinnedGraph = False
    , excludePostsInCotonoma = False
    }


decodeTimelineFilter : Decode.Decoder TimelineFilter
decodeTimelineFilter =
    Decode.map2 TimelineFilter
        (Decode.field "excludePinnedGraph" Decode.bool)
        (Decode.field "excludePostsInCotonoma" Decode.bool)


encodeTimelineFilter : TimelineFilter -> Encode.Value
encodeTimelineFilter filter =
    Encode.object
        [ ( "excludePinnedGraph", Encode.bool filter.excludePinnedGraph )
        , ( "excludePostsInCotonoma", Encode.bool filter.excludePostsInCotonoma )
        ]
