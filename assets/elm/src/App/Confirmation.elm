module App.Confirmation exposing (..)

import App.Messages


type alias Confirmation =
    { message : String
    , msgOnConfirm : App.Messages.Msg
    }


defaultConfirmation : Confirmation
defaultConfirmation =
    { message = ""
    , msgOnConfirm = App.Messages.NoOp
    }
