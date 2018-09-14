module App.Modals.ConfirmModal exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Utils.Modal as Modal
import App.Messages exposing (Msg(..))


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
