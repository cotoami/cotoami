module Components.ConnectModal exposing (..)

import Html exposing (..)
import Modal
import App.Messages exposing (..)
import App.Model exposing (..)


view : Model -> Html Msg
view model =
    Modal.view
        "connect-modal"
        (if model.connectModalOpen then
            Just (modalConfig model)
         else
            Nothing
        )


modalConfig : Model -> Modal.Config Msg
modalConfig model =
    { closeMessage = CloseConnectModal
    , title = "Connect cotos"
    , content = div []
        [ 
        ]
    , buttons = []
    }
