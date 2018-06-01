module App.Views.PinnedCotos exposing (..)

import Dict
import Html exposing (..)
import Html.Keyed
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Exts.Maybe exposing (isJust)
import Util.EventUtil exposing (onClickWithoutPropagation, onLinkButtonClick)
import Util.HtmlUtil exposing (faIcon, materialIcon)
import App.Types.Context exposing (CotoSelection, Context, isSelected, isServerOwner)
import App.Types.Coto exposing (Coto, CotoId, Cotonoma, CotonomaKey)
import App.Types.Graph exposing (Graph, Connection)
import App.Messages exposing (..)
import App.Views.Coto exposing (InboundConnection, defaultActionConfig)


view : Context -> Graph -> Html Msg
view context graph =
    div [ id "pinned-cotos" ]
        [ div
            [ class "column-header" ]
            [ div [ class "view-switch" ]
                [ a
                    [ classList
                        [ ( "tool-button", True )
                        , ( "document-view", True )
                        , ( "disabled", True )
                        ]
                    ]
                    [ materialIcon "view_stream" Nothing ]
                , a
                    [ classList
                        [ ( "tool-button", True )
                        , ( "graph-view", True )
                        ]
                    ]
                    [ materialIcon "share" Nothing ]
                ]
            ]
        , div
            [ id "pinned-cotos-body", class "column-body" ]
            [ pinnedCotos context graph ]
        ]


pinnedCotos : Context -> Graph -> Html Msg
pinnedCotos context graph =
    graph.rootConnections
        |> List.reverse
        |> List.indexedMap
            (\index connection ->
                connectionDiv
                    context
                    graph
                    (InboundConnection
                        Nothing
                        connection
                        (List.length graph.rootConnections)
                        index
                    )
            )
        |> Html.Keyed.node "div" [ class "root-connections" ]


connectionDiv : Context -> Graph -> InboundConnection -> ( String, Html Msg )
connectionDiv context graph inbound =
    graph.cotos
        |> Dict.get inbound.connection.end
        |> Maybe.map
            (\coto ->
                ( inbound.connection.key
                , div
                    [ class "outbound-conn" ]
                    [ cotoDiv context graph inbound coto ]
                )
            )
        |> Maybe.withDefault
            ( inbound.connection.key, div [] [] )


cotoDiv : Context -> Graph -> InboundConnection -> Coto -> Html Msg
cotoDiv context graph inbound coto =
    let
        elementId =
            "pinned-" ++ coto.id

        cotonomaCotoId =
            context.cotonoma |> Maybe.map (\cotonoma -> cotonoma.cotoId)
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
                [ unpinButtonDiv context inbound.connection coto.id
                , App.Views.Coto.headerDiv
                    context
                    graph
                    (Just inbound)
                    { defaultActionConfig
                        | toggleReorderMode = Just ToggleReorderMode
                    }
                    elementId
                    coto
                , App.Views.Coto.parentsDiv graph cotonomaCotoId coto.id
                , App.Views.Coto.bodyDivByCoto context elementId coto
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
