module App.Types.Graph.Render exposing (render)

import App.Ports.Graph exposing (Edge, Node)
import App.Submodels.Context exposing (Context)
import App.Types.Connection exposing (Connection)
import App.Types.Coto exposing (Coto, Cotonoma)
import App.Types.Graph exposing (Graph)
import Dict
import Exts.Maybe exposing (isJust)
import Set


render : Context context -> Graph -> Cmd msg
render context graph =
    graph
        |> toTopicGraph
        |> convert context
        |> App.Ports.Graph.renderGraph


convert : Context context -> Graph -> App.Ports.Graph.Model
convert context graph =
    let
        rootNode =
            currentCotonomaAsNode context

        nodes =
            graph.cotos
                |> Dict.values
                |> List.map (cotoToNode graph)

        rootEdges =
            graph.rootConnections
                |> List.map (\conn -> connectionToEdge rootNode.id conn)

        edges =
            graph.connections
                |> Dict.toList
                |> List.map
                    (\( sourceId, conns ) ->
                        List.map (\conn -> connectionToEdge sourceId conn) conns
                    )
                |> List.concat
    in
    { rootNodeId = rootNode.id
    , nodes = rootNode :: nodes
    , edges = rootEdges ++ edges
    }


currentCotonomaAsNode : Context context -> Node
currentCotonomaAsNode context =
    context.cotonoma
        |> Maybe.map
            (\cotonoma ->
                { id = cotonoma.cotoId
                , name = cotonoma.name
                , pinned = False
                , asCotonoma = True
                , imageUrl = Maybe.map .avatarUrl cotonoma.owner
                , incomings = 0
                , outgoings = 0
                }
            )
        |> Maybe.withDefault
            { id = "home"
            , name = ""
            , pinned = False
            , asCotonoma = False
            , imageUrl = Nothing
            , incomings = 0
            , outgoings = 0
            }


cotoToNode : Graph -> Coto -> Node
cotoToNode graph coto =
    { id = coto.id
    , name = App.Types.Coto.toTopic coto |> Maybe.withDefault ""
    , pinned = App.Types.Graph.pinned coto.id graph
    , asCotonoma = isJust coto.asCotonoma
    , imageUrl = Maybe.map .avatarUrl coto.amishi
    , incomings = coto.incomings |> Maybe.withDefault 0
    , outgoings = coto.outgoings |> Maybe.withDefault 0
    }


connectionToEdge : String -> Connection -> Edge
connectionToEdge sourceId connection =
    { source = sourceId
    , target = connection.end
    , linkingPhrase = connection.linkingPhrase
    }


toTopicGraph : Graph -> Graph
toTopicGraph graph =
    let
        topicCotos =
            graph.cotos
                |> Dict.filter
                    (\cotoId coto ->
                        isJust (App.Types.Coto.toTopic coto)
                    )
    in
    { graph | cotos = topicCotos }
        |> deleteInvalidConnections
        |> excludeUnreachables


excludeUnreachables : Graph -> Graph
excludeUnreachables graph =
    let
        reachableCotos =
            Dict.filter
                (\cotoId coto -> Set.member cotoId graph.reachableCotoIds)
                graph.cotos
    in
    { graph | cotos = reachableCotos }
        |> deleteInvalidConnections


deleteInvalidConnections : Graph -> Graph
deleteInvalidConnections graph =
    let
        rootConnections =
            graph.rootConnections
                |> List.filter (\conn -> Dict.member conn.end graph.cotos)

        connections =
            graph.connections
                |> Dict.toList
                |> List.filterMap
                    (\( sourceId, conns ) ->
                        if Dict.member sourceId graph.cotos then
                            Just
                                ( sourceId
                                , List.filter
                                    (\conn -> Dict.member conn.end graph.cotos)
                                    conns
                                )

                        else
                            Nothing
                    )
                |> Dict.fromList
    in
    { graph | rootConnections = rootConnections, connections = connections }
