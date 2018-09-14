module App.Views.CotoSelectionMsg exposing (Msg(..))

import App.Types.Coto exposing (CotoId)


type Msg
    = ColumnToggle
    | DeselectingCoto CotoId
    | DeselectCoto
    | ClearSelection
