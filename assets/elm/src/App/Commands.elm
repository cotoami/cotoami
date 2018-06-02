module App.Commands exposing (..)

import Dom
import Dom.Scroll
import Task exposing (andThen, attempt)
import Process
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
        |> andThen (\_ -> (Dom.Scroll.toRight elementId))
        |> attempt (\_ -> msg)


scrollTimelineToBottom : msg -> Cmd msg
scrollTimelineToBottom msg =
    scrollToBottom "timeline" msg


scrollTimelineByQuickEditorOpen : msg -> Cmd msg
scrollTimelineByQuickEditorOpen msg =
    Process.sleep (1 * Time.millisecond)
        |> andThen (\_ -> (Dom.Scroll.y "timeline"))
        |> andThen (\y -> (Dom.Scroll.toY "timeline" (y + 142)))
        |> attempt (\_ -> msg)


initScrollPositionOfPinnedCotos : msg -> Cmd msg
initScrollPositionOfPinnedCotos msg =
    scrollToTop "pinned-cotos-body" msg


scrollPinnedCotosToBottom : msg -> Cmd msg
scrollPinnedCotosToBottom msg =
    scrollToBottom "pinned-cotos-body" msg


scrollToTop : String -> msg -> Cmd msg
scrollToTop elementId msg =
    Process.sleep (100 * Time.millisecond)
        |> andThen (\_ -> (Dom.Scroll.toTop elementId))
        |> attempt (\_ -> msg)


scrollToBottom : String -> msg -> Cmd msg
scrollToBottom elementId msg =
    Process.sleep (100 * Time.millisecond)
        |> andThen (\_ -> (Dom.Scroll.toBottom elementId))
        |> attempt (\_ -> msg)


focus : String -> msg -> Cmd msg
focus elementId msg =
    Dom.focus elementId |> attempt (\_ -> msg)
