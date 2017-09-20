module Components.ConfirmModal.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Util.Modal as Modal
import App.Messages exposing (Msg(..))
import Components.ConfirmModal.Model exposing (..)


view : Model -> Html Msg
view model =
    Modal.view
        "confirm-modal"
        (Just (modalConfig model))


modalConfig : Model -> Modal.Config Msg
modalConfig model =
    { closeMessage = CloseModal
    , title = "Confirm"
    , content = div [] [ text model.message ]
    , buttons =
        [ button [ class "button", onClick CloseModal ] [ text "Cancel" ]
        , button [ class "button button-primary", onClick Confirm ] [ text "OK" ]
        ]
    }
