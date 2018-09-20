module App.Views.Navigation exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Exts.Maybe exposing (isNothing)
import Utils.EventUtil exposing (onLinkButtonClick)
import Utils.HtmlUtil exposing (materialIcon)
import App.I18n.Keys as I18nKeys
import App.Types.Coto exposing (Cotonoma)
import App.Types.Graph exposing (Graph)
import App.Model exposing (Model)
import App.Messages exposing (Msg(HomeClick))
import App.Submodels.Context exposing (Context)
import App.Views.Cotonomas


view : Model -> List (Html Msg)
view model =
    [ div [ id "navigation-content" ]
        [ model.session
            |> Maybe.map (\_ -> homeNav model)
            |> Maybe.withDefault Utils.HtmlUtil.none
        , div
            [ class "cotonomas-nav" ]
            [ model.cotonoma
                |> Maybe.map (cotonomaNav model)
                |> Maybe.withDefault Utils.HtmlUtil.none
            , recentCotonomasDiv model model.graph model.recentCotonomas
            ]
        ]
    ]


homeNav : Model -> Html Msg
homeNav model =
    div
        [ classList
            [ ( "home-nav", True )
            , ( "in", isNothing model.cotonoma )
            ]
        ]
        [ (model.cotonoma
            |> Maybe.map
                (\_ -> a [ class "home", onLinkButtonClick HomeClick ])
            |> Maybe.withDefault
                (span [ class "home" ])
          )
            [ materialIcon "home" Nothing
            , text (model.i18nText I18nKeys.MyHome)
            ]
        ]


cotonomaNav : Model -> Cotonoma -> Html Msg
cotonomaNav model cotonoma =
    div [ class "current-cotonoma" ]
        [ div [ class "navigation-title" ]
            [ text (model.i18nText I18nKeys.Navigation_Current) ]
        , App.Views.Cotonomas.cotonomaDiv
            model
            model.graph
            "current-cotonoma"
            cotonoma
        , div [ class "sub-cotonomas" ]
            [ App.Views.Cotonomas.view
                model
                model.graph
                "sub-cotonomas"
                model.subCotonomas
            ]
        ]


recentCotonomasDiv : Context context -> Graph -> List Cotonoma -> Html Msg
recentCotonomasDiv context graph cotonomas =
    if List.isEmpty cotonomas then
        Utils.HtmlUtil.none
    else
        div [ class "recent-cotonomas" ]
            [ div [ class "navigation-title" ]
                [ text (context.i18nText I18nKeys.Navigation_Recent) ]
            , App.Views.Cotonomas.view context graph "recent-cotonomas" cotonomas
            ]
