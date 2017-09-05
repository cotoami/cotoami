module App.Commands exposing (..)

import Dom.Scroll
import Task exposing (andThen, attempt)
import Process
import Time


-- https://medium.com/elm-shorts/how-to-turn-a-msg-into-a-cmd-msg-in-elm-5dd095175d84
sendMsg : msg -> Cmd msg
sendMsg msg =
    Task.succeed msg |> Task.perform identity


scrollTimelineToBottom : msg -> Cmd msg
scrollTimelineToBottom msg =
    scrollToBottom "timeline" msg


scrollToBottom : String -> msg -> Cmd msg
scrollToBottom elementId msg =
    Process.sleep (1 * Time.millisecond)
        |> andThen (\_ -> (Dom.Scroll.toBottom elementId))
        |> attempt (\_ -> msg)
