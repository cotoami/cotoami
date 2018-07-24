module App.Views.Navigation exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Exts.Maybe exposing (isNothing)
import Util.EventUtil exposing (onLinkButtonClick)
import Util.HtmlUtil exposing (materialIcon)
import App.Types.Coto exposing (Cotonoma)
import App.Types.Graph exposing (Graph)
import App.Types.Context exposing (Context)
import App.Model exposing (Model)
import App.Messages exposing (Msg(HomeClick))
import App.Views.Cotonomas


view : Model -> List (Html Msg)
view model =
    [ div [ id "navigation-content" ]
        [ model.context.session
            |> Maybe.map (\_ -> homeNav model)
            |> Maybe.withDefault Util.HtmlUtil.none
        , div
            [ class "cotonomas-nav" ]
            [ model.context.cotonoma
                |> Maybe.map (cotonomaNav model)
                |> Maybe.withDefault Util.HtmlUtil.none
            , recentCotonomasDiv model.context model.graph model.recentCotonomas
            ]
        ]
    ]


homeNav : Model -> Html Msg
homeNav model =
    div
        [ classList
            [ ( "home-nav", True )
            , ( "in", isNothing model.context.cotonoma )
            ]
        ]
        [ (model.context.cotonoma
            |> Maybe.map
                (\_ -> a [ class "home", onLinkButtonClick HomeClick ])
            |> Maybe.withDefault
                (span [ class "home" ])
          )
            [ materialIcon "home" Nothing
            , text "My Home"
            ]
        ]


cotonomaNav : Model -> Cotonoma -> Html Msg
cotonomaNav model cotonoma =
    div [ class "current-cotonoma" ]
        [ div [ class "navigation-title" ] [ text "Current" ]
        , App.Views.Cotonomas.cotonomaDiv
            model.context
            model.graph
            "current-cotonoma"
            cotonoma
        , div [ class "sub-cotonomas" ]
            [ App.Views.Cotonomas.view
                model.context
                model.graph
                "sub-cotonomas"
                model.subCotonomas
            ]
        ]


recentCotonomasDiv : Context -> Graph -> List Cotonoma -> Html Msg
recentCotonomasDiv context graph cotonomas =
    if List.isEmpty cotonomas then
        Util.HtmlUtil.none
    else
        div [ class "recent-cotonomas" ]
            [ div [ class "navigation-title" ] [ text "Recent" ]
            , App.Views.Cotonomas.view context graph "recent-cotonomas" cotonomas
            ]
