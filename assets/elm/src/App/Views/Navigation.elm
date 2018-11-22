module App.Views.Navigation exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Exts.Maybe exposing (isNothing)
import Utils.EventUtil exposing (onLinkButtonClick)
import Utils.HtmlUtil exposing (materialIcon, faIcon)
import App.I18n.Keys as I18nKeys
import App.Types.Coto exposing (Cotonoma)
import App.Types.Watch exposing (Watch)
import App.Types.Graph exposing (Graph)
import App.Messages exposing (Msg(MoveToHome))
import App.Submodels.Context exposing (Context)
import App.Views.Cotonomas


type alias ViewModel model =
    Context
        { model
            | globalCotonomas : List Cotonoma
            , recentCotonomas : List Cotonoma
            , subCotonomas : List Cotonoma
            , watchlist : List Watch
            , graph : Graph
        }


view : ViewModel model -> List (Html Msg)
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
            , globalCotonomasDiv model
            , recentCotonomasDiv model
            ]
        ]
    ]


homeNav : ViewModel model -> Html Msg
homeNav model =
    div
        [ classList
            [ ( "home-nav", True )
            , ( "in", isNothing model.cotonoma )
            ]
        ]
        [ (model.cotonoma
            |> Maybe.map
                (\_ -> a [ class "home", onLinkButtonClick MoveToHome ])
            |> Maybe.withDefault
                (span [ class "home" ])
          )
            [ materialIcon "home" Nothing
            , text (model.i18nText I18nKeys.MyHome)
            ]
        ]


cotonomaNav : ViewModel model -> Cotonoma -> Html Msg
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


globalCotonomasDiv : ViewModel model -> Html Msg
globalCotonomasDiv model =
    if List.isEmpty model.globalCotonomas then
        Utils.HtmlUtil.none
    else
        div [ class "global-cotonomas" ]
            [ div [ class "navigation-title" ]
                [ faIcon "thumb-tack" Nothing ]
            , App.Views.Cotonomas.view
                model
                model.graph
                "global-cotonomas"
                model.globalCotonomas
            ]


recentCotonomasDiv : ViewModel model -> Html Msg
recentCotonomasDiv model =
    if List.isEmpty model.recentCotonomas then
        Utils.HtmlUtil.none
    else
        div [ class "recent-cotonomas" ]
            [ div [ class "navigation-title" ]
                [ text (model.i18nText I18nKeys.Navigation_Recent) ]
            , App.Views.Cotonomas.view
                model
                model.graph
                "recent-cotonomas"
                model.recentCotonomas
            ]
