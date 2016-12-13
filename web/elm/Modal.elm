module Modal exposing (view)

import Html
import Html exposing (..)
import Html.Attributes exposing (..)

view : Html msg
view =
    div [ class "modal modal-open" ]
        [ div [ class "modal-inner" ]
            [ div [ class "modal-content" ]
                [ div [ class "modal-close-icon" ]
                    [ a [ href "#", class "close-modal" ] [ text "x" ] ]
                , div [ class "modal-content-inner" ]
                    [ h4 [] [ text "Sign in with your email" ]
                    , p [] [ text "Cotoami doesn't use passwords. Just enter your email address and we'll send you a sign-in (or sign-up) link." ]
                    , div []
                        [ input [ type_ "email", class "u-full-width", placeholder "test@example.com" ] [] ]
                    ]
                , hr [ class "modal-buttons-seperator" ] []
                , div [ class "modal-buttons" ]
                    [ button [ class "button close-modal" ] [ text "Cancel" ]
                    , button [ class "button button-primary close-modal" ] [ text "OK" ]
                    ]
                ]
            ]
        ]
