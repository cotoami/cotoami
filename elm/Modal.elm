module Modal exposing (Config, view)

import Html
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Exts.Maybe exposing (maybe, isJust)

type alias Config msg =
    { closeMessage : msg
    , title : String
    , content : Html msg
    , buttons : List (Html msg)
    }


view : String -> Maybe (Config msg) -> Html msg
view modalId maybeConfig =
    div [ id modalId
        , classList
            [ ( "modal", True )
            , ( "modal-open", isJust maybeConfig )
            ]
        ]
        [ div [ class "modal-inner" ]
            [ (case maybeConfig of
                Nothing -> div [ class "modal-content" ] []
                Just config -> modalContent config
              )
            ]
        ]


modalContent : Config msg -> Html msg
modalContent config =
    div [ class "modal-content" ]
        [ div [ class "modal-close-icon" ]
            [ a [ class "close-modal", onClick config.closeMessage ]
                [ i [ class "fa fa-times", (attribute "aria-hidden" "true") ] [] ]
            ]
        , div [ class "modal-content-inner" ]
            [ h4 [] [ text config.title ]
            , config.content
            ]
        , hr [ class "modal-buttons-seperator" ] []
        , div [ class "modal-buttons" ] config.buttons
        ]
