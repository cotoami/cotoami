module Components.Timeline.Messages exposing (..)

import Http
import Keyboard exposing (..)
import Components.Timeline.Model exposing (Post)


type Msg
    = NoOp
    | PostsFetched (Result Http.Error (List Post))
    | ImageLoaded
    | PostClick Int
    | EditorFocus
    | EditorBlur
    | EditorInput String
    | EditorKeyDown KeyCode
    | Post
    | Posted (Result Http.Error Post)
    | PostOpen Post
    | CotonomaClick String
