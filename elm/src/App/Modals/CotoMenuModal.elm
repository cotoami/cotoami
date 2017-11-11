module App.Modals.CotoMenuModal exposing (view)

import Html exposing (..)
import Util.Modal as Modal
import App.Types.Coto exposing (Coto)
import App.Messages exposing (Msg(..))


view : Coto -> Html Msg
view coto =
    Modal.view "coto-menu-modal" (Just (modalConfig coto))


modalConfig : Coto -> Modal.Config Msg
modalConfig coto =
    { closeMessage = CloseModal
    , title = text ""
    , content = div [] []
    , buttons = []
    }
