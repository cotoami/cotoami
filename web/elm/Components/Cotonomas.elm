module Components.Cotonomas exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import App.Model exposing (Model)
import App.Messages exposing (Msg)


view : Model -> Html Msg
view model =
    div [ id "cotonomas" ]
        [ div [ class "coto-as-cotonoma" ]
            [ a []
                [ i [ class "material-icons" ] [ text "exit_to_app" ]
                , span [ class "cotonoma-name" ] [ text "Kubernetes" ]
                ]
            ]
        , div [ class "coto-as-cotonoma" ]
            [ a []
                [ i [ class "material-icons" ] [ text "exit_to_app" ]
                , span [ class "cotonoma-name" ] [ text "Elixir" ]
                ]
            ]
        , div [ class "coto-as-cotonoma" ]
            [ a []
                [ i [ class "material-icons" ] [ text "exit_to_app" ]
                , span [ class "cotonoma-name" ] [ text "Groovy" ]
                ]
            ]
        , div [ class "coto-as-cotonoma" ]
            [ a []
                [ i [ class "material-icons" ] [ text "exit_to_app" ]
                , span [ class "cotonoma-name" ] [ text "Elm" ]
                ]
            ]
        , div [ class "coto-as-cotonoma" ]
            [ a []
                [ i [ class "material-icons" ] [ text "exit_to_app" ]
                , span [ class "cotonoma-name" ] [ text "CSS" ]
                ]
            ]
        , div [ class "coto-as-cotonoma" ]
            [ a []
                [ i [ class "material-icons" ] [ text "exit_to_app" ]
                , span [ class "cotonoma-name" ] [ text "Scala" ]
                ]
            ]
        , div [ class "coto-as-cotonoma" ]
            [ a []
                [ i [ class "material-icons" ] [ text "exit_to_app" ]
                , span [ class "cotonoma-name" ] [ text "Docker" ]
                ]
            ]
        ]
