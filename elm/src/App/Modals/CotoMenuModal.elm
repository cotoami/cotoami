module App.Modals.CotoMenuModal exposing (view)

import Html exposing (..)
import Util.Modal as Modal
import App.Types.Coto exposing (Coto)
import App.Model exposing (Model)
import App.Messages exposing (Msg(..))


view : Model -> Html Msg
view model =
    model.cotoMenu
        |> Maybe.map (\coto -> modalConfig coto model)
        |> Modal.view "coto-menu-modal"


modalConfig : Coto -> Model -> Modal.Config Msg
modalConfig coto model =
    { closeMessage = CloseModal
    , title = text ""
    , content = div [] []
    , buttons = []
    }
