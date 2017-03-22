module Components.Navigation exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import App.Types exposing (Cotonoma)
import App.Model exposing (Model)
import App.Messages exposing (Msg)
import Components.Cotonomas


view : Model -> List (Html Msg)
view model =
    [ div [ id "navigation-content" ]
        [ case model.cotonoma of
            Just cotonoma -> cotonomaNav cotonoma
            Nothing -> div [] []
        , recentCotonomasNav model.cotonomas
        ]
    ]


cotonomaNav : Cotonoma -> Html Msg
cotonomaNav cotonoma =
    div [ class "members" ] 
        [ div [ class "navigation-title" ] [ text "Members" ]
        , div [ class "amishi member owner" ]
            [ img [ class "avatar", src cotonoma.owner.avatarUrl ] []
            , span [ class "name" ] [ text cotonoma.owner.displayName ]
            ]
        ]
    

recentCotonomasNav : List Cotonoma -> Html Msg
recentCotonomasNav cotonomas =
    div [ class "recent" ]
        [ div [ class "navigation-title" ] [ text "Recent" ]
        , Components.Cotonomas.view cotonomas
        ]
