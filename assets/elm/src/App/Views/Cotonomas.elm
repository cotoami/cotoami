module App.Views.Cotonomas exposing (cotonomaDiv, view, watchlist)

import App.Messages exposing (Msg(..))
import App.Submodels.Context exposing (Context)
import App.Submodels.CotoSelection
import App.Types.Coto exposing (Cotonoma, CotonomaHolder)
import App.Types.Watch exposing (Watch)
import App.Views.Coto
import App.Views.CotoToolbar
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Keyed
import Utils.EventUtil exposing (onClickWithoutPropagation, onLinkButtonClick)
import Utils.HtmlUtil exposing (materialIcon)


view : Context a -> String -> List CotonomaHolder -> Html Msg
view context title cotonomaHolders =
    Html.Keyed.node
        "div"
        [ class "cotonomas" ]
        (List.map
            (\holder ->
                ( toString holder.cotonoma.id
                , cotonomaDiv context Nothing title holder
                )
            )
            cotonomaHolders
        )


watchlist : Context a -> List Watch -> Html Msg
watchlist context watchlist =
    Html.Keyed.node
        "div"
        [ class "cotonomas" ]
        (List.map
            (\cotonomaHolder ->
                ( toString cotonomaHolder.cotonoma.id
                , cotonomaDiv context (Just watchlist) "watchlist" cotonomaHolder
                )
            )
            (List.map (\watch -> watch.cotonomaHolder) watchlist)
        )


cotonomaDiv : Context a -> Maybe (List Watch) -> String -> CotonomaHolder -> Html Msg
cotonomaDiv context maybeWatchlist listTitle cotonomaHolder =
    let
        cotonoma =
            cotonomaHolder.cotonoma

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
                        Nothing
                        (App.Types.Coto.toCoto cotonomaHolder)
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
