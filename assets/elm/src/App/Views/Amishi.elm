module App.Views.Amishi exposing (inline)

import App.Types.Amishi exposing (Amishi)
import Html exposing (..)
import Html.Attributes exposing (..)


inline : List String -> Amishi -> Html msg
inline additionalClasses amishi =
    let
        classes =
            ("amishi" :: additionalClasses)
                |> List.map (\class -> ( class, True ))
    in
    span [ classList classes ]
        [ img [ class "avatar", src amishi.avatarUrl ] []
        , span [ class "name" ] [ text amishi.displayName ]
        ]
