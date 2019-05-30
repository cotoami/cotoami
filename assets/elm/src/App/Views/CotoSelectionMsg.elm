module App.Views.CotoSelectionMsg exposing (Msg(..))

import App.Types.Coto exposing (CotoId)
import App.Types.Post exposing (Post)
import Http


type Msg
    = ColumnToggle
    | DeselectingCoto CotoId
    | DeselectCoto
    | ClearSelection
    | PinAsGroup
    | GroupingCotoPostedAndPinIt Int (Result Http.Error Post)
