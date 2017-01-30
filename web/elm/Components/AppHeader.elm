module Components.AppHeader exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import App.Model exposing (Model)
import App.Messages exposing (Msg(OpenSigninModal, OpenProfileModal, OpenCotonomaModal))


view : Model -> Html Msg
view model =
    div [ id "app-header" ]
        [ div [ class "location" ]
            (case model.cotonoma of
                Nothing -> 
                  [ i [ class "material-icons" ] [ text "home" ]
                  ]
                Just cotonoma ->
                  [ a [ class "to-home" ] [ i [ class "material-icons" ] [ text "home" ] ]
                  , i [ class "material-icons" ] [ text "navigate_next" ]
                  , span [ class "cotonoma-name" ] [ text cotonoma.name ]
                  ]
            )
        , (case model.session of
            Nothing -> 
                span [] []
            Just session -> 
                a [ class "add-cotonoma", title "Add Cotonoma", onClick OpenCotonomaModal ] 
                    [ i [ class "material-icons" ] [ text "add_circle_outline" ] ] 
          )
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
