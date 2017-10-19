module App.Views.PinnedCotos exposing (..)

import Dict
import Html exposing (..)
import Html.Keyed
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Exts.Maybe exposing (isJust)
import Util.EventUtil exposing (onClickWithoutPropagation, onLinkButtonClick)
import Util.HtmlUtil exposing (faIcon)
import App.Types.Context exposing (CotoSelection, Context, isSelected, isServerOwner)
import App.Types.Coto exposing (Coto, CotoId, Cotonoma, CotonomaKey)
import App.Types.Graph exposing (Graph, Connection)
import App.Messages exposing (..)
import App.Views.Coto


view : Context -> Graph -> Html Msg
view context graph =
    div [ id "pinned-cotos" ]
        [ div
            [ class "column-header" ]
            []
        , div
            [ id "pinned-cotos-body", class "column-body" ]
            [ pinnedCotos context graph ]
        ]


pinnedCotos : Context -> Graph -> Html Msg
pinnedCotos context graph =
    connectionsDiv "root-connections" graph.rootConnections context graph


connectionsDiv : String -> List Connection -> Context -> Graph -> Html Msg
connectionsDiv divClass connections context graph =
    Html.Keyed.node
        "div"
        [ class divClass ]
        (List.filterMap
            (\conn ->
                Maybe.map
                    (\coto ->
                        ( conn.key
                        , connectionDiv context graph conn coto
                        )
                    )
                    (Dict.get conn.end graph.cotos)
            )
            (List.reverse connections)
        )


connectionDiv : Context -> Graph -> Connection -> Coto -> Html Msg
connectionDiv context graph connection coto =
    div [ class "outbound-conn" ]
        [ cotoDiv context graph connection coto ]


cotoDiv : Context -> Graph -> Connection -> Coto -> Html Msg
cotoDiv context graph connection coto =
    let
        elementId =
            "pinned-" ++ coto.id
    in
        div
            [ App.Views.Coto.cotoClassList context
                elementId
                (Just coto.id)
                [ ( "pinned-coto", True )
                , ( "animated", True )
                , ( "fadeIn", True )
                ]
            , onClickWithoutPropagation (CotoClick elementId coto.id)
            , onMouseEnter (CotoMouseEnter elementId coto.id)
            , onMouseLeave (CotoMouseLeave elementId coto.id)
            ]
            [ div
                [ class "coto-inner" ]
                [ unpinButtonDiv context connection coto.id
                , App.Views.Coto.headerDiv CotonomaClick context graph coto
                , App.Views.Coto.bodyDiv context graph Nothing coto
                , App.Views.Coto.subCotosDiv context graph elementId coto
                ]
            ]


unpinButtonDiv : Context -> Connection -> CotoId -> Html Msg
unpinButtonDiv context connection cotoId =
    let
        maybeAmishiId =
            context.session
                |> Maybe.map (\session -> session.id)

        maybeCotonomaOwnerId =
            context.cotonoma
                |> Maybe.andThen (\cotonoma -> cotonoma.owner)
                |> Maybe.map (\owner -> owner.id)

        unpinnable =
            isServerOwner context
                || (maybeAmishiId == Just connection.amishiId)
                || ((isJust maybeAmishiId) && maybeAmishiId == maybeCotonomaOwnerId)
    in
        div [ class "unpin-button" ]
            [ if unpinnable then
                a
                    [ class "tool-button unpin"
                    , onLinkButtonClick (ConfirmUnpinCoto cotoId)
                    ]
                    [ faIcon "thumb-tack" Nothing ]
              else
                span
                    [ class "not-unpinnable" ]
                    [ faIcon "thumb-tack" Nothing ]
            ]
