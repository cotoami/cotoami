module App.Messages exposing (Msg(..))

import Http
import Keyboard exposing (..)
import App.Model exposing (Session, Coto)

type Msg
    = NoOp
    | SessionFetched (Result Http.Error Session)
    | CotosFetched (Result Http.Error (List Coto))
    | KeyDown KeyCode
    | KeyUp KeyCode
    | EditorFocus
    | EditorBlur
    | EditorInput String
    | EditorKeyDown KeyCode
    | Post
    | CotoPosted (Result Http.Error Coto)
    | SigninClick
    | SigninModalClose
    | SigninEmailInput String
    | SigninWithAnonymousCotosCheck Bool
    | SigninRequestClick
    | SigninRequestDone (Result Http.Error String)
