module App.Views.Navigation exposing
    ( ViewModel
    , currentCotonomaNav
    , globalCotonomasDiv
    , homeNav
    , recentCotonomasDiv
    , view
    , watchlistDiv
    )

import App.I18n.Keys as I18nKeys
import App.Messages exposing (Msg(MoveToHome))
import App.Submodels.Context exposing (Context)
import App.Types.Coto exposing (Cotonoma)
import App.Views.Cotonomas
import Exts.Maybe exposing (isNothing)
import Html exposing (..)
import Html.Attributes exposing (..)
import Utils.EventUtil exposing (onLinkButtonClick)
import Utils.HtmlUtil exposing (faIcon, materialIcon)


type alias ViewModel model =
    Context
        { model
            | globalCotonomas : List Cotonoma
            , recentCotonomas : List Cotonoma
            , subCotonomas : List Cotonoma
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
                |> Maybe.map (currentCotonomaNav model)
                |> Maybe.withDefault Utils.HtmlUtil.none
            , globalCotonomasDiv model
            , watchlistDiv model
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


currentCotonomaNav : ViewModel model -> Cotonoma -> Html Msg
currentCotonomaNav model cotonoma =
    div [ class "current-cotonoma" ]
        [ div [ class "navigation-title" ]
            [ text (model.i18nText I18nKeys.Navigation_Current) ]
        , App.Views.Cotonomas.cotonomaDiv
            model
            Nothing
            "current-cotonoma"
            cotonoma
        , div [ class "sub-cotonomas" ]
            [ App.Views.Cotonomas.view model "sub-cotonomas" model.subCotonomas
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
            , App.Views.Cotonomas.view model "global-cotonomas" model.globalCotonomas
            ]


watchlistDiv : ViewModel model -> Html Msg
watchlistDiv model =
    if List.isEmpty model.watchlist then
        Utils.HtmlUtil.none

    else
        div [ class "watchlist" ]
            [ div [ class "navigation-title" ]
                [ materialIcon "visibility" Nothing
                , text (model.i18nText I18nKeys.Navigation_Watchlist)
                ]
            , App.Views.Cotonomas.watchlist model model.watchlist
            ]


recentCotonomasDiv : ViewModel model -> Html Msg
recentCotonomasDiv model =
    if List.isEmpty model.recentCotonomas then
        Utils.HtmlUtil.none

    else
        div [ class "recent-cotonomas" ]
            [ div [ class "navigation-title" ]
                [ text (model.i18nText I18nKeys.Navigation_Recent) ]
            , App.Views.Cotonomas.view model "recent-cotonomas" model.recentCotonomas
            ]
