module App.Modals.AppInfoModal exposing (view)

import App.Messages as AppMsg
import App.Submodels.Context exposing (Context)
import Html exposing (..)
import Html.Attributes exposing (..)
import Utils.Modal


view : Context context -> Html AppMsg.Msg
view context =
    Utils.Modal.view "app-info-modal" (modalConfig context)


modalConfig : Context context -> Utils.Modal.Config AppMsg.Msg
modalConfig context =
    { closeMessage = AppMsg.CloseModal
    , title = text ""
    , content =
        div []
            [ appLogoDiv
            , basicInfo
            ]
    , buttons = []
    }


appLogoDiv : Html AppMsg.Msg
appLogoDiv =
    div [ id "app-logo" ]
        [ img [ class "app-icon", src "/images/logo/vertical.svg" ] [] ]


basicInfo : Html AppMsg.Msg
basicInfo =
    div [ id "app-basic-info" ]
        [ p []
            [ text "Being developed as open source at "
            , a [ href "https://github.com/cotoami/cotoami", target "_blank" ]
                [ text "GitHub" ]
            ]
        ]
