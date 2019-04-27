module App.Modals.AppInfoModal exposing (view)

import App.Messages as AppMsg
import App.Submodels.Context exposing (Context)
import Html exposing (..)
import Utils.Modal


view : Context context -> Html AppMsg.Msg
view context =
    Utils.Modal.view "app-info-modal" (modalConfig context)


modalConfig : Context context -> Utils.Modal.Config AppMsg.Msg
modalConfig context =
    { closeMessage = AppMsg.CloseModal
    , title = text ""
    , content = div [] []
    , buttons = []
    }
