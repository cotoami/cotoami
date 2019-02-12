module App.Commands exposing (focus, initScrollPositionOfPinnedCotos, scrollGraphExplorationToRight, scrollPinnedCotosToBottom, scrollTimelineByQuickEditorOpen, scrollTimelineToBottom, scrollToBottom, scrollToRight, scrollToTop, scrollTraversalsPaginationToRight, sendMsg)

import Dom
import Dom.Scroll
import Process
import Task
import Time


sendMsg : msg -> Cmd msg
sendMsg msg =
    Task.succeed msg |> Task.perform identity


scrollGraphExplorationToRight : msg -> Cmd msg
scrollGraphExplorationToRight msg =
    scrollToRight "graph-exploration" msg


scrollTraversalsPaginationToRight : msg -> Cmd msg
scrollTraversalsPaginationToRight msg =
    scrollToRight "traversals-pagination" msg


scrollToRight : String -> msg -> Cmd msg
scrollToRight elementId msg =
    Process.sleep (100 * Time.millisecond)
        |> Task.andThen (\_ -> Dom.Scroll.toRight elementId)
        |> Task.attempt (\_ -> msg)


scrollTimelineToBottom : (Float -> msg) -> Cmd msg
scrollTimelineToBottom tag =
    scrollToBottom tag "timeline"


scrollTimelineByQuickEditorOpen : msg -> Cmd msg
scrollTimelineByQuickEditorOpen msg =
    Process.sleep (1 * Time.millisecond)
        |> Task.andThen (\_ -> Dom.Scroll.y "timeline")
        |> Task.andThen (\y -> Dom.Scroll.toY "timeline" (y + 142))
        |> Task.attempt (\_ -> msg)


initScrollPositionOfPinnedCotos : msg -> Cmd msg
initScrollPositionOfPinnedCotos msg =
    scrollToTop "pinned-cotos-body" msg


scrollPinnedCotosToBottom : (Float -> msg) -> Cmd msg
scrollPinnedCotosToBottom tag =
    scrollToBottom tag "pinned-cotos-body"


scrollToTop : String -> msg -> Cmd msg
scrollToTop elementId msg =
    Process.sleep (100 * Time.millisecond)
        |> Task.andThen (\_ -> Dom.Scroll.toTop elementId)
        |> Task.attempt (\_ -> msg)


scrollToBottom : (Float -> msg) -> String -> Cmd msg
scrollToBottom tag elementId =
    Process.sleep (100 * Time.millisecond)
        |> Task.andThen (\_ -> Dom.Scroll.toBottom elementId)
        |> Task.andThen (\_ -> Dom.Scroll.y elementId)
        |> Task.attempt (\result -> Result.withDefault -1 result |> tag)


focus : String -> msg -> Cmd msg
focus elementId msg =
    Dom.focus elementId
        |> Task.attempt (\_ -> msg)
