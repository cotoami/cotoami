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
import App.Markdown
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
    div
        [ classList
            [ ( "coto", True )
            , ( "selectable", True )
            , ( "focus", Just coto.id == context.cotoFocus )
            , ( "selected", isSelected coto.id context )
            , ( "animated", True )
            , ( "fadeIn", True )
            ]
        , onClickWithoutPropagation (CotoClick coto.id)
        , onMouseEnter (CotoMouseEnter coto.id)
        , onMouseLeave (CotoMouseLeave coto.id)
        ]
        [ div
            [ class "coto-inner" ]
            [ App.Views.Coto.headerDiv CotonomaClick context.cotonoma graph coto
            , bodyDiv context graph coto
            , App.Views.Coto.openTraversalButtonDiv OpenTraversal (Just coto.id) graph
            ]
        ]


bodyDiv : Context -> Graph -> Coto -> Html Msg
bodyDiv context graph coto =
    App.Views.Coto.bodyDiv
        context
        graph
        { openCoto = Just (OpenCoto coto)
        , selectCoto = Just SelectCoto
        , openTraversal = Just OpenTraversal
        , cotonomaClick = CotonomaClick
        , deleteConnection = Just (ConfirmUnpinCoto coto.id)
        , markdown = App.Markdown.markdown
        }
        { cotoId = Just coto.id
        , content = coto.content
        , asCotonoma = coto.asCotonoma
        , cotonomaKey = coto.cotonomaKey
        }
