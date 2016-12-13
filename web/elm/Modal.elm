module Modal exposing (view)

import Html
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Exts.Maybe exposing (maybe, isJust)

type alias Config msg =
    { closeMessage : msg
    , okMessage : msg
    , title : String
    , content : Html msg
    }
    
    
view : Maybe (Config msg) -> Html msg
view maybeConfig = 
    div [ classList [ ( "modal", True ), ( "modal-open", (isJust maybeConfig)) ] ]
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
            [ a [ href "#", class "close-modal", onClick config.closeMessage ] [ text "x" ] ]
        , div [ class "modal-content-inner" ]
            [ h4 [] [ text config.title ]
            , config.content 
            ]
        , hr [ class "modal-buttons-seperator" ] []
        , div [ class "modal-buttons" ]
            [ button [ class "button close-modal", onClick config.closeMessage ] [ text "Cancel" ]
            , button [ class "button button-primary close-modal", onClick config.okMessage ] [ text "OK" ]
            ]
        ]
