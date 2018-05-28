module App.Modals.EditorModalMsg exposing (..)

import Util.Keyboard.Event exposing (KeyboardEvent)


type Msg
    = EditorInput String
    | SummaryInput String
    | TogglePreview
    | EditorKeyDown KeyboardEvent
    | Post
    | PostCotonoma
    | Save
    | SetNewCotoMode
    | SetNewCotonomaMode
