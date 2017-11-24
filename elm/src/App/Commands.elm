module App.Commands exposing (..)

import Dom
import Dom.Scroll
import Task exposing (andThen, attempt)
import Process
import Time


-- https://medium.com/elm-shorts/how-to-turn-a-msg-into-a-cmd-msg-in-elm-5dd095175d84


sendMsg : msg -> Cmd msg
sendMsg msg =
    Task.succeed msg |> Task.perform identity


scrollGraphExplorationToRight : msg -> Cmd msg
scrollGraphExplorationToRight msg =
    scrollToRight "graph-exploration" msg


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


scrollPinnedCotosToBottom : msg -> Cmd msg
scrollPinnedCotosToBottom msg =
    scrollToBottom "pinned-cotos-body" msg


scrollToBottom : String -> msg -> Cmd msg
scrollToBottom elementId msg =
    Process.sleep (100 * Time.millisecond)
        |> andThen (\_ -> (Dom.Scroll.toBottom elementId))
        |> attempt (\_ -> msg)


focus : String -> msg -> Cmd msg
focus elementId msg =
    Dom.focus elementId |> attempt (\_ -> msg)
