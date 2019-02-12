module App.Modals.ConfirmModal exposing (view)

import App.I18n.Keys as I18nKeys
import App.Messages exposing (Msg(..))
import App.Submodels.Context exposing (Context)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Utils.Modal as Modal


view : Context context -> String -> Html Msg
view context confirmMessage =
    Modal.view
        "confirm-modal"
        (Just (modalConfig context confirmMessage))


modalConfig : Context context -> String -> Modal.Config Msg
modalConfig context confirmMessage =
    { closeMessage = CloseModal
    , title = text (context.i18nText I18nKeys.Confirm)
    , content = div [] [ text confirmMessage ]
    , buttons =
        [ button [ class "button", onClick CloseModal ] [ text "Cancel" ]
        , button [ class "button button-primary", onClick Confirm ] [ text "OK" ]
        ]
    }
