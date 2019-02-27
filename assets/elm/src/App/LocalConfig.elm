module App.LocalConfig exposing
    ( configure
    , saveTimelineFilter
    )

import App.Messages exposing (Msg)
import App.Model exposing (Model)
import App.Ports.LocalStorage
import App.Types.TimelineFilter exposing (TimelineFilter)
import App.Views.Flow
import Json.Decode as Decode
import Json.Encode as Encode exposing (Value)


configure : ( String, Value ) -> Model -> Model
configure ( key, value ) model =
    case key of
        "timeline.filter" ->
            value
                |> Decode.decodeValue (Decode.maybe decodeTimelineFilter)
                |> Result.withDefault Nothing
                |> Maybe.map
                    (\filter ->
                        { model | flowView = App.Views.Flow.setFilter filter model.flowView }
                    )
                |> Maybe.withDefault model

        _ ->
            model


saveTimelineFilter : TimelineFilter -> Cmd Msg
saveTimelineFilter filter =
    App.Ports.LocalStorage.setItem
        ( "timeline.filter"
        , encodeTimelineFilter filter
        )


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
