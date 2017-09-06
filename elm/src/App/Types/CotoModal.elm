module App.Types.CotoModal exposing (..)

import App.Types.Coto exposing (Coto)


type alias CotoModal =
    { open : Bool
    , coto : Maybe Coto
    }


initCotoModal : CotoModal
initCotoModal =
    { open = False
    , coto = Nothing
    }
