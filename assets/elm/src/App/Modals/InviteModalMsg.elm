module App.Modals.InviteModalMsg exposing (Msg(..))

import Http


type Msg
    = EmailInput String
    | SendInviteClick
    | SendInviteDone (Result Http.Error String)
