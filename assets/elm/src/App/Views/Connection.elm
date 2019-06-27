module App.Views.Connection exposing (linkingPhraseInputDiv)

import App.I18n.Keys as I18nKeys
import App.Submodels.Context exposing (Context)
import App.Types.Coto exposing (Coto)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
import Utils.HtmlUtil exposing (materialIcon)


linkingPhraseInputDiv : Context context -> (String -> msg) -> Maybe String -> Html msg
linkingPhraseInputDiv context onLinkingPhraseInput defaultLinkingPhrase =
    div
        [ class "linking-phrase-input" ]
        [ div [ class "arrow" ]
            [ materialIcon "arrow_downward" Nothing ]
        , div [ class "linking-phrase" ]
            [ input
                [ type_ "text"
                , class "u-full-width"
                , placeholder (context.i18nText I18nKeys.Connection_LinkingPhraseInput)
                , maxlength App.Types.Coto.cotonomaNameMaxlength
                , onInput onLinkingPhraseInput
                , defaultValue (defaultLinkingPhrase |> Maybe.withDefault "")
                ]
                []
            ]
        ]
