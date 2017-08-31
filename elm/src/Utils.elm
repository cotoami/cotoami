module Utils exposing (send)

import Task

-- https://medium.com/elm-shorts/how-to-turn-a-msg-into-a-cmd-msg-in-elm-5dd095175d84
send : msg -> Cmd msg
send msg =
    Task.succeed msg |> Task.perform identity
