module Utils.Modal exposing (Config, view)

import Exts.Maybe exposing (isJust, maybe)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Utils.HtmlUtil exposing (faIcon)


type alias Config msg =
    { closeMessage : msg
    , title : Html msg
    , content : Html msg
    , buttons : List (Html msg)
    }


view : String -> Maybe (Config msg) -> Html msg
view modalId maybeConfig =
    div
        [ id modalId
        , classList
            [ ( "modal", True )
            , ( "modal-open", isJust maybeConfig )
            ]
        ]
        [ div [ class "modal-inner" ]
            [ maybeConfig
                |> Maybe.map (\config -> modalContent config)
                |> Maybe.withDefault (div [ class "modal-content" ] [])
            ]
        ]


modalContent : Config msg -> Html msg
modalContent config =
    div [ class "modal-content" ]
        [ div [ class "modal-close-icon" ]
            [ a [ class "close-modal", onClick config.closeMessage ]
                [ faIcon "times" Nothing ]
            ]
        , div [ class "modal-content-inner" ]
            [ h4 [] [ config.title ]
            , config.content
            ]
        , hr [ class "modal-buttons-seperator" ] []
        , div [ class "modal-buttons" ] config.buttons
        ]
