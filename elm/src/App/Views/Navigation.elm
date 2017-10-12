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
        [ model.context.cotonoma
            |> Maybe.map cotonomaNav
            |> Maybe.withDefault (div [] [])
        , cotonomasDiv "sub-cotonomas" "Sub" model.context model.subCotonomas
        , cotonomasDiv "pinned-cotonomas" "Pinned" model.context model.pinnedCotonomas
        , cotonomasDiv "recent-cotonomas" "Recent" model.context model.recentCotonomas
        ]
    ]


cotonomaNav : Cotonoma -> Html Msg
cotonomaNav cotonoma =
    div [ class "owner" ]
        [ div [ class "navigation-title" ] [ text "Owner" ]
        , cotonoma.owner
            |> Maybe.map
                (\owner ->
                    div
                        [ class "amishi" ]
                        [ img [ class "avatar", src owner.avatarUrl ] []
                        , span [ class "name" ] [ text owner.displayName ]
                        ]
                )
            |> Maybe.withDefault (div [] [])
        ]


cotonomasDiv : String -> String -> Context -> List Cotonoma -> Html Msg
cotonomasDiv divClass title context cotonomas =
    if List.isEmpty cotonomas then
        div [] []
    else
        div [ class divClass ]
            [ div [ class "navigation-title" ] [ text title ]
            , App.Views.Cotonomas.view context divClass cotonomas
            ]
