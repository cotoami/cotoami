module App.Modals.EditorModalMsg exposing (..)

import Keyboard exposing (KeyCode)


type Msg
    = EditorInput String
    | SummaryInput String
    | TogglePreview
    | EditorKeyDown KeyCode
    | Post
    | PostCotonoma
    | Save
    | SetNewCotoMode
    | SetNewCotonomaMode
