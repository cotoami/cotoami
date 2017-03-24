module Components.Navigation exposing (..)

import Set
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Keyed
import App.Types exposing (Cotonoma, Amishi)
import App.Model exposing (Model)
import App.Messages exposing (Msg)
import Components.Cotonomas


view : Model -> List (Html Msg)
view model =
    [ div [ id "navigation-content" ]
        [ case model.cotonoma of
            Nothing -> div [] []
            Just cotonoma -> cotonomaNav model.memberPresence model.members cotonoma
        , if not (List.isEmpty model.subCotonomas) then
            subCotonomasNav model.subCotonomas
          else
            div [] []
        , recentCotonomasNav model.recentCotonomas
        ]
    ]


cotonomaNav : Set.Set Int -> List Amishi -> Cotonoma -> Html Msg
cotonomaNav memberPresence members cotonoma =
    div [ class "members" ] 
        [ div [ class "navigation-title" ] [ text "Members" ]
        , case cotonoma.owner of
            Nothing -> div [] []
            Just owner ->
                div 
                    [ classList
                        [ ( "member", True )
                        , ( "owner", True )
                        , ( "online", Set.member owner.id memberPresence )
                        ]
                    ]
                    [ img [ class "avatar", src owner.avatarUrl ] []
                    , span [ class "name" ] [ text owner.displayName ]
                    ]
        , Html.Keyed.node
            "div"
            [ class "members" ]
            (List.map 
                (\member -> 
                    ( toString member.id
                    , div 
                        [ classList
                            [ ( "member", True )
                            , ( "online", Set.member member.id memberPresence )
                            ]
                        ]
                        [ img [ class "avatar", src member.avatarUrl ] []
                        , span [ class "name" ] [ text member.displayName ]
                        ]
                    )
                ) 
                members
            )
        ]
    

subCotonomasNav : List Cotonoma -> Html Msg
subCotonomasNav cotonomas =
    div [ class "sub" ]
        [ div [ class "navigation-title" ] [ text "Sub" ]
        , Components.Cotonomas.view cotonomas
        ]


recentCotonomasNav : List Cotonoma -> Html Msg
recentCotonomasNav cotonomas =
    div [ class "recent" ]
        [ div [ class "navigation-title" ] [ text "Recent" ]
        , Components.Cotonomas.view cotonomas
        ]
