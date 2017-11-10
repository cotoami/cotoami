module App.Modals.EditorModalMsg exposing (..)

import Keyboard exposing (KeyCode)


type Msg
    = EditorInput String
    | SummaryInput String
    | Post
    | EditorKeyDown KeyCode
