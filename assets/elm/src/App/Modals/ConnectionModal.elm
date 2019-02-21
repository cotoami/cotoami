module App.Modals.ConnectionModal exposing (Model, initModel)

import App.I18n.Keys as I18nKeys
import App.Messages as AppMsg exposing (Msg(CloseModal))
import App.Submodels.Context exposing (Context)
import App.Types.Coto exposing (Coto)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Utils.Modal


type alias Model =
    { startCoto : Coto
    , endCoto : Coto
    , linkingPhrase : String
    }


initModel : Coto -> Coto -> Maybe String -> Model
initModel startCoto endCoto linkingPhrase =
    { startCoto = startCoto
    , endCoto = endCoto
    , linkingPhrase = linkingPhrase |> Maybe.withDefault ""
    }


view : Context context -> Model -> Html AppMsg.Msg
view context model =
    model
        |> modalConfig context
        |> Utils.Modal.view "connection-modal"


modalConfig : Context context -> Model -> Utils.Modal.Config AppMsg.Msg
modalConfig context model =
    { closeMessage = CloseModal
    , title = text (context.i18nText I18nKeys.ConnectionModal_Title)
    , content = div [] []
    , buttons =
        [ button [ class "button", onClick CloseModal ] [ text "Cancel" ]
        ]
    }
