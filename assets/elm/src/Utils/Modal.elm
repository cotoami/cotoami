module Utils.Modal exposing (Config, view)

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


view : String -> Config msg -> Html msg
view modalId config =
    div
        [ id modalId
        , class "modal"
        ]
        [ div [ class "modal-inner" ]
            [ modalContent config ]
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
