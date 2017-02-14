module Components.CotonomaModal.Messages exposing (..)

import Http
import Components.Timeline.Model exposing (Post)

type Msg
    = NoOp
    | Close
    | NameInput String
    | MemberEmailInput String
    | Post
    | Posted (Result Http.Error Post)
