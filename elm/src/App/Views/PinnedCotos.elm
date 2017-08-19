module App.Views.PinnedCotos exposing (..)

import Dict
import Html exposing (..)
import Html.Keyed
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Utils exposing (onClickWithoutPropagation)
import App.Types.Context exposing (CotoSelection, Context, isSelected)
import App.Types.Coto exposing (Coto, CotoId, Cotonoma, CotonomaKey)
import App.Types.Graph exposing (Graph, Connection)
import App.Messages exposing (..)
import App.Views.Coto


view : Context -> Graph -> Html Msg
view context graph =
    div [ id "pinned-cotos" ]
        [ div
            [ class "column-header" ]
            [ i [ class "pinned fa fa-thumb-tack", (attribute "aria-hidden" "true") ] []
            ]
        , div
            [ class "column-body" ]
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
                case Dict.get conn.end graph.cotos of
                    Nothing ->
                        Nothing

                    Just coto ->
                        Just
                            ( conn.key
                            , connectionDiv context graph coto
                            )
            )
            (List.reverse connections)
        )


connectionDiv : Context -> Graph -> Coto -> Html Msg
connectionDiv context graph coto =
    div [ class "outbound-conn" ]
        [ cotoDiv context graph coto ]


cotoDiv : Context -> Graph -> Coto -> Html Msg
cotoDiv context graph coto =
    let
        elementId = "pinned-" ++ coto.id
    in
        div
            [ App.Views.Coto.cotoClassList context elementId (Just coto.id)
                [ ( "animated", True )
                , ( "fadeIn", True )
                ]
            , onClickWithoutPropagation (CotoClick elementId coto.id)
            , onMouseEnter (CotoMouseEnter elementId coto.id)
            , onMouseLeave (CotoMouseLeave elementId coto.id)
            ]
            [ div
                [ class "coto-inner" ]
                [ App.Views.Coto.headerDiv CotonomaClick context.cotonoma graph coto
                , bodyDiv context graph coto
                , App.Views.Coto.subCotosDiv context graph elementId coto
                ]
            ]


bodyDiv : Context -> Graph -> Coto -> Html Msg
bodyDiv context graph coto =
    let
        defaultBodyConfig = App.Views.Coto.defaultBodyConfig Nothing coto
    in
        App.Views.Coto.bodyDivWithConfig
            context
            graph
            { defaultBodyConfig
            | deleteConnection = Just (ConfirmUnpinCoto coto.id)
            }
            { cotoId = Just coto.id
            , content = coto.content
            , asCotonoma = coto.asCotonoma
            , cotonomaKey = coto.cotonomaKey
            }
