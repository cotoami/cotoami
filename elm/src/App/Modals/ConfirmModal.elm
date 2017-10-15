module App.Modals.ConfirmModal exposing (ConfirmRequest, defaultConfirmRequest, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Util.Modal as Modal
import App.Messages exposing (Msg(..))


type alias ConfirmRequest =
    { message : String
    , msgOnConfirm : App.Messages.Msg
    }


defaultConfirmRequest : ConfirmRequest
defaultConfirmRequest =
    { message = ""
    , msgOnConfirm = App.Messages.NoOp
    }


view : String -> Html Msg
view confirmMessage =
    Modal.view
        "confirm-modal"
        (Just (modalConfig confirmMessage))


modalConfig : String -> Modal.Config Msg
modalConfig confirmMessage =
    { closeMessage = CloseModal
    , title = text "Confirm"
    , content = div [] [ text confirmMessage ]
    , buttons =
        [ button [ class "button", onClick CloseModal ] [ text "Cancel" ]
        , button [ class "button button-primary", onClick Confirm ] [ text "OK" ]
        ]
    }
