module Components.AppHeader exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import App.Model exposing (Model)
import App.Messages exposing (Msg(OpenSigninModal))

view : Model -> Html Msg
view model =
    div [ id "app-header" ]
        [ div [ class "title" ]
            [ i [ class "material-icons" ] [ text "home" ]
            ]
        , div [ class "user" ]
            (case model.session of
                Nothing -> 
                    [ a [ href "#", title "Sign in", onClick OpenSigninModal ] 
                        [ i [ class "material-icons" ] [ text "perm_identity" ] ] 
                    ]
                Just session -> 
                    [ img [ class "avatar", src session.avatarUrl ] [] ]
            )
        ]
