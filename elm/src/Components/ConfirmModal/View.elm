module Components.ConfirmModal.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Util.Modal as Modal
import Components.ConfirmModal.Model exposing (..)
import Components.ConfirmModal.Messages exposing (..)


view : Model -> Html Msg
view model =
    Modal.view
        "confirm-modal"
        (if model.open then
            Just (modalConfig model)
         else
            Nothing
        )


modalConfig : Model -> Modal.Config Msg
modalConfig model =
    { closeMessage = Close
    , title = "Confirm"
    , content = div [] [ text model.message ]
    , buttons =
        [ button [ class "button", onClick Close ] [ text "Cancel" ]
        , button [ class "button button-primary", onClick Confirm ] [ text "OK" ]
        ]
    }
