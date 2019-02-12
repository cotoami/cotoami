port module App.Ports.Graph exposing
    ( destroyGraph
    , nodeClicked
    , renderCotoGraph
    , resizeGraph
    )

import App.Types.Coto exposing (Coto, CotoId, Cotonoma)
import App.Types.Graph exposing (Graph)
import Dict
import Exts.Maybe exposing (isJust)


port renderGraph :
    { rootNodeId : String, nodes : List Node, edges : List Edge }
    -> Cmd msg


port resizeGraph : () -> Cmd msg


port destroyGraph : () -> Cmd msg


port nodeClicked : (String -> msg) -> Sub msg


type alias Node =
    { id : String
    , name : String
    , pinned : Bool
    , asCotonoma : Bool
    , imageUrl : Maybe String
    }


type alias Edge =
    { source : String
    , target : String
    }


cotoToNode : Graph -> Coto -> Node
cotoToNode graph coto =
    { id = coto.id
    , name = App.Types.Coto.toTopic coto |> Maybe.withDefault ""
    , pinned = App.Types.Graph.pinned coto.id graph
    , asCotonoma = isJust coto.asCotonoma
    , imageUrl = Maybe.map .avatarUrl coto.amishi
    }


currentCotonomaToNode : Graph -> Maybe Cotonoma -> Node
currentCotonomaToNode graph currentCotonoma =
    currentCotonoma
        |> Maybe.map
            (\cotonoma ->
                { id = cotonoma.cotoId
                , name = cotonoma.name
                , pinned = False
                , asCotonoma = True
                , imageUrl = Maybe.map .avatarUrl cotonoma.owner
                }
            )
        |> Maybe.withDefault
            { id = "home"
            , name = ""
            , pinned = False
            , asCotonoma = False
            , imageUrl = Nothing
            }


renderCotoGraph : Maybe Cotonoma -> Graph -> Cmd msg
renderCotoGraph currentCotonoma graph =
    doRenderCotoGraph
        (currentCotonomaToNode graph currentCotonoma)
        (App.Types.Graph.toTopicGraph graph)


doRenderCotoGraph : Node -> Graph -> Cmd msg
doRenderCotoGraph root graph =
    let
        nodes =
            graph.cotos
                |> Dict.values
                |> List.map (cotoToNode graph)

        rootEdges =
            graph.rootConnections
                |> List.map
                    (\conn ->
                        { source = root.id
                        , target = conn.end
                        }
                    )

        edges =
            graph.connections
                |> Dict.toList
                |> List.map
                    (\( sourceId, conns ) ->
                        List.map
                            (\conn ->
                                { source = sourceId
                                , target = conn.end
                                }
                            )
                            conns
                    )
                |> List.concat
    in
    renderGraph
        { rootNodeId = root.id
        , nodes = root :: nodes
        , edges = rootEdges ++ edges
        }
