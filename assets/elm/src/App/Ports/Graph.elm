port module App.Ports.Graph
    exposing
        ( renderCotoGraph
        , resizeGraph
        , destroyGraph
        , nodeClicked
        )

import Dict
import App.Types.Graph exposing (Graph)
import App.Types.Coto exposing (Coto, CotoId, Cotonoma)


port renderGraph :
    { rootNodeId : String, nodes : List Node, edges : List Edge }
    -> Cmd msg


port resizeGraph : () -> Cmd msg


port destroyGraph : () -> Cmd msg


port nodeClicked : (String -> msg) -> Sub msg


type alias Node =
    { id : String
    , name : String
    , asCotonoma : Bool
    , imageUrl : Maybe String
    }


type alias Edge =
    { source : String
    , target : String
    }


cotoToNode : Coto -> Node
cotoToNode coto =
    { id = coto.id
    , name = App.Types.Coto.toTopic coto |> Maybe.withDefault ""
    , asCotonoma = coto.asCotonoma
    , imageUrl = coto.amishi |> Maybe.map (\amishi -> amishi.avatarUrl)
    }


renderCotoGraph : Maybe Cotonoma -> Graph -> Cmd msg
renderCotoGraph maybeCotonoma graph =
    doRenderCotoGraph
        (maybeCotonoma
            |> Maybe.map
                (\cotonoma ->
                    { id = cotonoma.cotoId
                    , name = cotonoma.name
                    , asCotonoma = True
                    , imageUrl =
                        cotonoma.owner
                            |> Maybe.map (\owner -> owner.avatarUrl)
                    }
                )
            |> Maybe.withDefault
                { id = "home"
                , name = ""
                , asCotonoma = False
                , imageUrl = Nothing
                }
        )
        (App.Types.Graph.toTopicGraph graph)


doRenderCotoGraph : Node -> Graph -> Cmd msg
doRenderCotoGraph root graph =
    let
        nodes =
            graph.cotos
                |> Dict.values
                |> List.map cotoToNode

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
