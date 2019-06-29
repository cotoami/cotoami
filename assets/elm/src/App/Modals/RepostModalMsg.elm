module App.Modals.RepostModalMsg exposing (Msg(..))

import App.Types.Coto exposing (Cotonoma)
import App.Types.Post exposing (Post)
import Http


type Msg
    = CotonomaNameInput String
    | Repost
    | Reposted (Result Http.Error Post)
    | CotonomaFetched Int (Result Http.Error Cotonoma)
