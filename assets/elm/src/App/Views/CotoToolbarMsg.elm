module App.Views.CotoToolbarMsg exposing (Msg(..))

import App.Types.Coto exposing (Coto, CotoId)
import App.Types.Connection exposing (Direction)


type Msg
    = ConfirmConnect CotoId Direction
    | OpenCotoMenuModal Coto
    | ConfirmDisconnect ( CotoId, CotoId )
