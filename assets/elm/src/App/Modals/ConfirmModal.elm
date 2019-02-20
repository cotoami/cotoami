module App.Modals.ConfirmModal exposing (view)

import App.I18n.Keys as I18nKeys
import App.Messages exposing (Msg(..))
import App.Submodels.Context exposing (Context)
import App.Submodels.Modals exposing (Confirmation)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Utils.Modal as Modal


view : Context context -> Confirmation -> Html Msg
view context confirmation =
    confirmation
        |> modalConfig context
        |> Modal.view "confirm-modal"


modalConfig : Context context -> Confirmation -> Modal.Config Msg
modalConfig context confirmation =
    { closeMessage = CloseModal
    , title = text (context.i18nText I18nKeys.Confirm)
    , content = div [] [ text confirmation.message ]
    , buttons =
        [ button [ class "button", onClick CloseModal ] [ text "Cancel" ]
        , button
            [ class "button button-primary"
            , onClick (Confirm confirmation.msgOnConfirm)
            ]
            [ text "OK" ]
        ]
    }
