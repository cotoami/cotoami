module App.Modals.CotoMenuModalMsg exposing (Msg(..))

import App.Types.Coto exposing (CotonomaStats)
import Http


type Msg
    = Init
    | CotonomaStatsFetched (Result Http.Error CotonomaStats)
