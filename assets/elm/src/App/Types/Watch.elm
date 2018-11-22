module App.Types.Watch exposing (Watch)

import App.Types.Coto exposing (Cotonoma)


type alias Watch =
    { cotonoma : Cotonoma
    , lastPostTimestamp : Maybe Int
    }
