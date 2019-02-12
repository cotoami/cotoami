module App.Views.CotoToolbarMsg exposing (Msg(..))

import App.Types.Connection exposing (Direction)
import App.Types.Coto exposing (Coto, CotoId)


type Msg
    = ConfirmConnect CotoId Direction
    | OpenCotoMenuModal Coto
    | ConfirmDisconnect ( CotoId, CotoId )
