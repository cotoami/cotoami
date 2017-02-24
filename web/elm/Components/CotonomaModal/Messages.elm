module Components.CotonomaModal.Messages exposing (..)

import Http
import App.Types exposing (Amishi)
import Components.Timeline.Model exposing (Post)


type Msg
    = NoOp
    | Close
    | NameInput String
    | MemberEmailInput String
    | Post
    | Posted (Result Http.Error Post)
    | AddMember
    | RemoveMember String
    | AmishiFetched (Result Http.Error Amishi)
