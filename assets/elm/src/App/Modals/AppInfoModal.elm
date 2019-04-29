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
            , basicInfoDiv context
            , creditsDiv
            ]
    , buttons = []
    }


appLogoDiv : Html AppMsg.Msg
appLogoDiv =
    div [ id "app-logo" ]
        [ img [ class "app-icon", src "/images/logo/vertical.svg" ] [] ]


basicInfoDiv : Context context -> Html AppMsg.Msg
basicInfoDiv context =
    div [ id "app-basic-info" ]
        [ div [ id "app-version" ] [ text ("Version " ++ context.clientVersion) ]
        , div []
            [ text "Being developed as open source at "
            , a [ href "https://github.com/cotoami/cotoami", target "_blank" ]
                [ text "GitHub" ]
            ]
        ]


creditsDiv : Html AppMsg.Msg
creditsDiv =
    div [ id "credits" ]
        [ div [ class "title" ] [ text "Credits:" ]
        , div [ class "content" ]
            [ ul []
                [ li []
                    [ a [ href "https://neo4j.com/", target "_blank" ]
                        [ text "Neo4j" ]
                    ]
                , li []
                    [ a [ href "https://www.postgresql.org/", target "_blank" ]
                        [ text "PostgreSQL" ]
                    ]
                , li []
                    [ a [ href "https://redis.io/", target "_blank" ]
                        [ text "Redis" ]
                    ]
                , li []
                    [ a [ href "https://elixir-lang.org/", target "_blank" ]
                        [ text "Elixir" ]
                    , text " & "
                    , a [ href "https://phoenixframework.org/", target "_blank" ]
                        [ text "Phoenix" ]
                    ]
                , li []
                    [ a [ href "https://elm-lang.org/", target "_blank" ]
                        [ text "Elm" ]
                    ]
                , li []
                    [ text "The app logo designed by "
                    , a [ href "https://github.com/reallinfo", target "_blank" ]
                        [ text "@reallinfo" ]
                    ]
                , li []
                    [ a [ href "https://material.io/tools/icons/", target "_blank" ]
                        [ text "Material icons" ]
                    , text " made by "
                    , a [ href "https://policies.google.com/terms", target "_blank" ]
                        [ text "Google" ]
                    ]
                , li []
                    [ text "Icons made by "
                    , a [ href "https://fontawesome.com/", target "_blank" ]
                        [ text "Font Awesome" ]
                    ]
                , li []
                    [ text "Icons made by "
                    , a [ href "https://www.freepik.com/", target "_blank" ]
                        [ text "Freepik" ]
                    , text " from "
                    , a [ href "https://www.flaticon.com/", target "_blank" ]
                        [ text "Flaticon" ]
                    , text " licensed by "
                    , a [ href "http://creativecommons.org/licenses/by/3.0/", target "_blank" ]
                        [ text "CC 3.0 BY" ]
                    ]
                ]
            ]
        ]
