module App.Views.Navigation exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import App.Types.Coto exposing (Cotonoma)
import App.Types.Graph exposing (Graph)
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
        , cotonomasDiv model.context model.graph "sub-cotonomas" "Sub" model.subCotonomas
        , cotonomasDiv model.context model.graph "pinned-cotonomas" "Pinned" model.pinnedCotonomas
        , cotonomasDiv model.context model.graph "recent-cotonomas" "Recent" model.recentCotonomas
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


cotonomasDiv : Context -> Graph -> String -> String -> List Cotonoma -> Html Msg
cotonomasDiv context graph divClass title cotonomas =
    if List.isEmpty cotonomas then
        div [] []
    else
        div [ class divClass ]
            [ div [ class "navigation-title" ] [ text title ]
            , App.Views.Cotonomas.view context graph divClass cotonomas
            ]
