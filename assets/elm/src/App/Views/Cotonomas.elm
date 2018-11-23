module App.Views.Cotonomas exposing (view, cotonomaDiv)

import Html exposing (..)
import Html.Keyed
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Utils.HtmlUtil exposing (materialIcon)
import Utils.EventUtil exposing (onLinkButtonClick, onClickWithoutPropagation)
import App.Types.Coto exposing (Cotonoma)
import App.Types.Graph exposing (Graph)
import App.Types.Watch exposing (Watch)
import App.Messages exposing (Msg(..))
import App.Submodels.Context exposing (Context)
import App.Views.Coto
import App.Views.CotoToolbar


view : Context a -> Graph -> List Watch -> String -> List Cotonoma -> Html Msg
view context graph watchlist title cotonomas =
    Html.Keyed.node
        "div"
        [ class "cotonomas" ]
        (List.map
            (\cotonoma ->
                ( toString cotonoma.id
                , cotonomaDiv context graph watchlist title cotonoma
                )
            )
            cotonomas
        )


cotonomaDiv : Context a -> Graph -> List Watch -> String -> Cotonoma -> Html Msg
cotonomaDiv context graph watchlist listTitle cotonoma =
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
                , ( "selected", App.Submodels.Context.isSelected (Just cotonoma.cotoId) context )
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
                , if App.Types.Watch.anyUnreadCotosInCotonoma watchlist cotonoma then
                    materialIcon "fiber_manual_record" (Just "unread")
                  else
                    Utils.HtmlUtil.none
                ]
            , div [ class "touch-space-to-open-tools" ] []
            , context.session
                |> Maybe.map
                    (\session ->
                        App.Views.CotoToolbar.view
                            context
                            session
                            graph
                            Nothing
                            elementId
                            (App.Types.Coto.toCoto cotonoma)
                    )
                |> Maybe.withDefault Utils.HtmlUtil.none
            ]
