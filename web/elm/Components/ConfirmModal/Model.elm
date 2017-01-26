module Components.ConfirmModal.Model exposing (..)

type alias Model =
    { open : Bool
    , message : String
    }


initModel : Model
initModel =
    { open = False
    , message = ""
    }
