module App.Views.CotoToolbarMsg exposing (Msg(..))

import App.Types.Coto exposing (Coto, CotoId)
import App.Types.Graph exposing (Direction)


type Msg
    = ConfirmConnect CotoId Direction
    | OpenCotoMenuModal Coto
    | ConfirmDeleteConnection ( CotoId, CotoId )
