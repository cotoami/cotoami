module Components.ConfirmModal.Model exposing (..)

import App.Messages


type alias Model =
    { message : String
    , msgOnConfirm : App.Messages.Msg
    }


initModel : Model
initModel =
    { message = ""
    , msgOnConfirm = App.Messages.NoOp
    }
