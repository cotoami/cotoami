module App.Modals.EditorModalMsg exposing (..)

import Http
import Util.Keyboard.Event exposing (KeyboardEvent)
import App.Types.Coto exposing (Coto)
import App.Types.Post exposing (Post)


type Msg
    = EditorInput String
    | SummaryInput String
    | TogglePreview
    | EditorKeyDown KeyboardEvent
    | ShareCotonomaCheck Bool
    | Post
    | ConfirmPostAndConnect String (Maybe String)
    | PostedAndSubordinateToCoto Int Coto (Result Http.Error Post)
    | PostCotonoma
    | Save
    | SetNewCotoMode
    | SetNewCotonomaMode
