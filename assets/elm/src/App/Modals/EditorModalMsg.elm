module App.Modals.EditorModalMsg exposing (..)

import Http
import Utils.Keyboard.Event exposing (KeyboardEvent)
import App.Types.Coto exposing (Coto, CotoContent)
import App.Types.Post exposing (Post)


type Msg
    = EditorInput String
    | SummaryInput String
    | TogglePreview
    | EditorKeyDown KeyboardEvent
    | ShareCotonomaCheck Bool
    | Post
    | ConfirmPostAndConnect CotoContent
    | PostedAndSubordinateToCoto Int Coto (Result Http.Error Post)
    | PostCotonoma
    | CotonomaPosted Int (Result Http.Error Post)
    | Save
    | SetNewCotoMode
    | SetNewCotonomaMode
