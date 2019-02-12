module App.Modals.InviteModalMsg exposing (Msg(..))

import App.Types.Amishi exposing (Amishi)
import Http


type Msg
    = Init
    | InviteesFetched (Result Http.Error (List Amishi))
    | EmailInput String
    | SendInviteClick
    | SendInviteDone (Result Http.Error String)
