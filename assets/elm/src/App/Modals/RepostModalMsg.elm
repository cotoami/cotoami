module App.Modals.RepostModalMsg exposing (Msg(..))

import App.Types.Post exposing (Post)
import Http


type Msg
    = CotonomaNameInput String
    | Repost
    | Reposted (Result Http.Error Post)
