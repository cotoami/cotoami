module Components.CotonomaModal.Messages exposing (..)

import Http
import App.Types.Amishi exposing (Amishi)
import App.Types.Post exposing (Post)


type Msg
    = NoOp
    | NameInput String
    | MemberEmailInput String
    | Post
    | Posted (Result Http.Error Post)
    | AddMember
    | RemoveMember String
    | AmishiFetched (Result Http.Error Amishi)
