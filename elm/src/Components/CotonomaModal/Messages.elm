module Components.CotonomaModal.Messages exposing (..)

import Http
import App.Types.Amishi exposing (Amishi)


type Msg
    = NoOp
    | NameInput String
    | MemberEmailInput String
    | AddMember
    | RemoveMember String
    | AmishiFetched (Result Http.Error Amishi)
