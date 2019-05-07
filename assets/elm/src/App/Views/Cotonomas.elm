module App.Views.Cotonomas exposing (cotonomaDiv, view, watchlist)

import App.Messages exposing (Msg(..))
import App.Submodels.Context exposing (Context)
import App.Submodels.CotoSelection
import App.Types.Coto exposing (Cotonoma)
import App.Types.Watch exposing (Watch)
import App.Views.Coto
import App.Views.CotoToolbar
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Keyed
import Utils.EventUtil exposing (onClickWithoutPropagation, onLinkButtonClick)
import Utils.HtmlUtil exposing (materialIcon)


view : Context a -> String -> List Cotonoma -> Html Msg
view context title cotonomas =
    Html.Keyed.node
        "div"
        [ class "cotonomas" ]
        (List.map
            (\cotonoma ->
                ( toString cotonoma.id
                , cotonomaDiv context Nothing title cotonoma
                )
            )
            cotonomas
        )


watchlist : Context a -> List Watch -> Html Msg
watchlist context watchlist =
    Html.Keyed.node
        "div"
        [ class "cotonomas" ]
        (List.map
            (\cotonoma ->
                ( toString cotonoma.id
                , cotonomaDiv context (Just watchlist) "watchlist" cotonoma
                )
            )
            (List.map (\watch -> watch.cotonoma) watchlist)
        )


cotonomaDiv : Context a -> Maybe (List Watch) -> String -> Cotonoma -> Html Msg
cotonomaDiv context maybeWatchlist listTitle cotonoma =
    let
        elementId =
            listTitle ++ cotonoma.cotoId

        inCotonoma =
            context.cotonoma
                |> Maybe.map (\current -> current.id == cotonoma.id)
                |> Maybe.withDefault False
    in
    div
        [ classList
            [ ( "coto-as-cotonoma", True )
            , ( "element-focus", Just elementId == context.elementFocus )
            , ( "coto-focus", Just cotonoma.cotoId == context.cotoFocus )
            , ( "selected", App.Submodels.CotoSelection.isSelected cotonoma.cotoId context )
            , ( "in", inCotonoma )
            , ( "not-active", not (App.Types.Coto.revisedBefore cotonoma) )
            ]
        , onClickWithoutPropagation (CotoClick elementId cotonoma.cotoId)
        , onMouseEnter (CotoMouseEnter elementId cotonoma.cotoId)
        , onMouseLeave (CotoMouseLeave elementId cotonoma.cotoId)
        ]
        [ div [ class "cotonoma-link" ]
            [ if inCotonoma then
                App.Views.Coto.cotonomaLabel cotonoma.owner cotonoma

              else
                App.Views.Coto.cotonomaLink context CotonomaClick cotonoma.owner cotonoma
            , unreadMark maybeWatchlist cotonoma
            ]
        , div [ class "touch-space-to-open-tools" ] []
        , context.session
            |> Maybe.map
                (\session ->
                    App.Views.CotoToolbar.view
                        context
                        session
                        Nothing
                        elementId
                        (App.Types.Coto.toCoto cotonoma)
                )
            |> Maybe.withDefault Utils.HtmlUtil.none
        ]


unreadMark : Maybe (List Watch) -> Cotonoma -> Html Msg
unreadMark maybeWatchlist cotonoma =
    maybeWatchlist
        |> Maybe.map
            (\watchlist ->
                if App.Types.Watch.anyUnreadCotosInCotonoma watchlist cotonoma then
                    materialIcon "fiber_manual_record" (Just "unread")

                else
                    Utils.HtmlUtil.none
            )
        |> Maybe.withDefault Utils.HtmlUtil.none
