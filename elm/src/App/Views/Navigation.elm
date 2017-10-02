module App.Views.Navigation exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import App.Types.Coto exposing (Cotonoma)
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
                cotonomaNav cotonoma
        , if not (List.isEmpty model.subCotonomas) then
            subCotonomasNav model.context model.subCotonomas
          else
            div [] []
        , recentCotonomasNav model.context model.recentCotonomas
        ]
    ]


cotonomaNav : Cotonoma -> Html Msg
cotonomaNav cotonoma =
    div [ class "owner" ]
        [ div [ class "navigation-title" ] [ text "Owner" ]
        , case cotonoma.owner of
            Nothing ->
                div [] []

            Just owner ->
                div
                    [ class "amishi" ]
                    [ img [ class "avatar", src owner.avatarUrl ] []
                    , span [ class "name" ] [ text owner.displayName ]
                    ]
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
