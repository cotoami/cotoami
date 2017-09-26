module App.Views.Navigation exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Keyed
import App.Types.Coto exposing (Cotonoma)
import App.Types.Amishi exposing (Amishi)
import App.Types.MemberPresences exposing (MemberPresences, isPresent)
import App.Types.Context exposing (Context)
import App.Model exposing (Model)
import App.Messages exposing (Msg)
import App.Views.Cotonomas


view : Model -> List (Html Msg)
view model =
    [ div [ id "navigation-content" ]
        [ case model.context.cotonoma of
            Nothing ->
                div [] []

            Just cotonoma ->
                cotonomaNav model.memberPresences model.members cotonoma
        , if not (List.isEmpty model.subCotonomas) then
            subCotonomasNav model.context model.subCotonomas
          else
            div [] []
        , recentCotonomasNav model.context model.recentCotonomas
        ]
    ]


cotonomaNav : MemberPresences -> List Amishi -> Cotonoma -> Html Msg
cotonomaNav memberPresences members cotonoma =
    div [ class "members" ]
        [ div [ class "navigation-title" ] [ text "Members" ]
        , case cotonoma.owner of
            Nothing ->
                div [] []

            Just owner ->
                div
                    [ classList
                        [ ( "member", True )
                        , ( "owner", True )
                        , ( "online", isPresent owner.id memberPresences )
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
                            , ( "online", isPresent member.id memberPresences )
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


subCotonomasNav : Context -> List Cotonoma -> Html Msg
subCotonomasNav context cotonomas =
    div [ class "sub" ]
        [ div [ class "navigation-title" ] [ text "Sub" ]
        , App.Views.Cotonomas.view context "sub-cotonomas" cotonomas
        ]


recentCotonomasNav : Context -> List Cotonoma -> Html Msg
recentCotonomasNav context cotonomas =
    div [ class "recent" ]
        [ div [ class "navigation-title" ] [ text "Recent" ]
        , App.Views.Cotonomas.view context "recent-cotonomas" cotonomas
        ]
