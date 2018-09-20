module App.Modals.CotoMenuModalMsg exposing (Msg(..))

import Http
import App.Types.Coto exposing (CotonomaStats)


type Msg
    = Init
    | CotonomaStatsFetched (Result Http.Error CotonomaStats)
