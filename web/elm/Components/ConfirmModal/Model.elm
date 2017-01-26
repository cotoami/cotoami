module Components.ConfirmModal.Model exposing (..)

import App.Messages


type alias Model =
    { open : Bool
    , message : String
    , msgOnConfirm : App.Messages.Msg
    }


initModel : Model
initModel =
    { open = False
    , message = ""
    , msgOnConfirm = App.Messages.NoOp
    }
