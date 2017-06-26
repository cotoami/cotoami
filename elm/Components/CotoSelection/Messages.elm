module Components.CotoSelection.Messages exposing (..)

import App.Types exposing (Coto, CotoId, CotonomaKey)


type Msg
    = NoOp
    | ConfirmPin
    | Pin
    | ClearSelection
    | OpenCoto Coto
    | CotonomaClick CotonomaKey
    | OpenTraversal CotoId
    | SetConnectMode Bool
    | CotoSelectionTitleInput String
    | ConfirmCreateGroupingCoto
    | CreateGroupingCoto
