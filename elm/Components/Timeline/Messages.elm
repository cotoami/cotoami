module Components.Timeline.Messages exposing (..)

import Http
import Json.Encode exposing (Value)
import Keyboard exposing (..)
import App.Types exposing (CotoId, CotonomaKey)
import Components.Timeline.Model exposing (Post)


type Msg
    = NoOp
    | PostsFetched (Result Http.Error (List Post))
    | ImageLoaded
    | PostClick CotoId
    | EditorFocus
    | EditorBlur
    | EditorInput String
    | EditorKeyDown KeyCode
    | Post
    | Posted (Result Http.Error Post)
    | OpenPost Post
    | CotonomaClick CotonomaKey
    | PostPushed Value
    | CotonomaPushed Post
    | SelectCoto CotoId
    | OpenTraversal CotoId
