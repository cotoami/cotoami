module App.Modals.ConnectionModal exposing
    ( Model
    , initModel
    , view
    )

import App.I18n.Keys as I18nKeys
import App.Messages as AppMsg exposing (Msg(CloseModal))
import App.Submodels.Context exposing (Context)
import App.Types.Coto exposing (Coto)
import App.Views.Connection
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Utils.HtmlUtil exposing (faIcon)
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
    , content = modalContent context model
    , buttons =
        [ button
            [ class "button disconnect"
            , onClick
                (AppMsg.OpenConfirmModal
                    (context.i18nText I18nKeys.ConfirmDisconnect)
                    (AppMsg.DeleteConnection ( model.startCoto.id, model.endCoto.id ))
                )
            ]
            [ faIcon "unlink" Nothing
            , text (context.i18nText I18nKeys.ConnectionModal_Disconnect)
            ]
        , button
            [ class "button button-primary"
            , autofocus True
            ]
            [ text (context.i18nText I18nKeys.Save) ]
        ]
    }


modalContent : Context context -> Model -> Html AppMsg.Msg
modalContent context model =
    div [ id "connection" ]
        [ div
            [ class "start" ]
            [ span [ class "node-title" ] [ text "From:" ]
            , App.Views.Connection.cotoDiv model.startCoto
            ]
        , App.Views.Connection.linkingPhraseInputDiv
            context
            (\_ -> AppMsg.NoOp)
        , div
            [ class "end" ]
            [ span [ class "node-title" ] [ text "To:" ]
            , App.Views.Connection.cotoDiv model.endCoto
            ]
        ]
