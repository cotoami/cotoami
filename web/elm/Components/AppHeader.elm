module Components.AppHeader exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import App.Model exposing (Model)
import App.Messages exposing (Msg(OpenSigninModal, OpenProfileModal))


view : Model -> Html Msg
view model =
    div [ id "app-header" ]
        [ div [ class "title" ]
            [ i [ class "material-icons" ] [ text "home" ]
            ]
        , div [ class "user" ]
            (case model.session of
                Nothing -> 
                    [ a [ title "Sign in", onClick OpenSigninModal ] 
                        [ i [ class "material-icons" ] [ text "perm_identity" ] ] 
                    ]
                Just session -> 
                    [ a [ title "Profile", onClick OpenProfileModal ] 
                        [ img [ class "avatar", src session.avatarUrl ] [] ] 
                    ]
            )
        ]
