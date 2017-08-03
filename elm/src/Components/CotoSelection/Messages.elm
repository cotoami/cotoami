module Components.CotoSelection.Messages exposing (..)

import Http
import App.Types.Coto exposing (Coto, CotoId, CotonomaKey)
import App.Types.Post exposing (Post)


type Msg
    = NoOp
    | DeselectingCoto CotoId
    | DeselectCoto
    | ConfirmPin
    | Pin
    | Pinned (Result Http.Error String)
    | ClearSelection
    | CotonomaClick CotonomaKey
    | OpenTraversal CotoId
    | SetConnectMode Bool
    | CotoSelectionTitleInput String
    | ConfirmCreateGroupingCoto
    | PostGroupingCoto
    | GroupingCotoPosted (Result Http.Error Post)
