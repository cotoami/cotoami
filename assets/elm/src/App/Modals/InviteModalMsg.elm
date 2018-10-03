module App.Modals.InviteModalMsg exposing (Msg(..))

import Http
import App.Types.Amishi exposing (Amishi)


type Msg
    = Init
    | InviteesFetched (Result Http.Error (List Amishi))
    | EmailInput String
    | SendInviteClick
    | SendInviteDone (Result Http.Error String)
