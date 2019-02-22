module App.Views.Connection exposing
    ( cotoContentDiv
    , cotoDiv
    , linkingPhraseInputDiv
    )

import App.I18n.Keys as I18nKeys
import App.Markdown
import App.Submodels.Context exposing (Context)
import App.Types.Coto exposing (Coto)
import App.Views.Coto
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
import Utils.HtmlUtil exposing (materialIcon)


cotoDiv : Coto -> Html msg
cotoDiv coto =
    coto.asCotonoma
        |> Maybe.map
            (\cotonoma ->
                div [ class "cotonoma-in-connection" ]
                    [ App.Views.Coto.cotonomaLabel cotonoma.owner cotonoma ]
            )
        |> Maybe.withDefault (cotoContentDiv coto.summary coto.content)


cotoContentDiv : Maybe String -> String -> Html msg
cotoContentDiv maybeSummary content =
    div [ class "coto-in-connection" ]
        [ maybeSummary
            |> Maybe.map
                (\summary ->
                    div [ class "coto-summary" ] [ text summary ]
                )
            |> Maybe.withDefault (App.Markdown.markdown content)
            |> (\contentDiv -> div [ class "coto-inner" ] [ contentDiv ])
        ]


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
