module App.Views.CotoToolbarMsg exposing (Msg(..))

import App.Types.Coto exposing (Coto, CotoId)


type Msg
    = OpenCotoMenuModal Coto
    | ConfirmDisconnect ( CotoId, CotoId )
