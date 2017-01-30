module Components.Timeline.Messages exposing (..)

import Http
import Keyboard exposing (..)
import Components.Timeline.Model exposing (Coto)


type Msg
    = NoOp
    | CotosFetched (Result Http.Error (List Coto))
    | ImageLoaded
    | CotoClick Int
    | EditorFocus
    | EditorBlur
    | EditorInput String
    | EditorKeyDown KeyCode
    | Post
    | CotoPosted (Result Http.Error Coto)
    | CotoOpen Coto
    | CotonomaClick String
