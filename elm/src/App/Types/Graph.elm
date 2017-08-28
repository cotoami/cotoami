module App.Types.Graph exposing (..)

import Dict
import Maybe exposing (withDefault)
import App.Types.Coto exposing (Coto, CotoId)


type alias Connection =
    { key : String
    , start : Maybe CotoId
    , end : CotoId
    }


initConnection : Maybe CotoId -> CotoId -> Connection
initConnection maybeStart end =
    let
        key = (withDefault "root" maybeStart) ++ " -> " ++ end
    in
        Connection key maybeStart end


type alias Graph =
    { cotos : Dict.Dict CotoId Coto
    , rootConnections : List Connection
    , connections : Dict.Dict CotoId (List Connection)
    }


defaultGraph : Graph
defaultGraph =
    { cotos = Dict.empty
    , rootConnections = []
    , connections = Dict.empty
    }


mergeSubgraph : Graph -> Graph -> Graph
mergeSubgraph subgraph graph =
    { graph
    | cotos = Dict.union subgraph.cotos graph.cotos
    , connections = Dict.union subgraph.connections graph.connections
    }


pinned : CotoId -> Graph -> Bool
pinned cotoId graph =
    List.any (\conn -> conn.end == cotoId) graph.rootConnections


member : CotoId -> Graph -> Bool
member cotoId graph =
    Dict.member cotoId graph.cotos


getCoto : CotoId -> Graph -> Maybe Coto
getCoto cotoId graph =
    Dict.get cotoId graph.cotos


addCoto : Coto -> Graph -> Graph
addCoto coto graph =
    { graph
    | cotos = Dict.insert coto.id coto graph.cotos
    }


connected : CotoId -> CotoId -> Graph -> Bool
connected startId endId graph =
    case Dict.get startId graph.connections of
        Nothing -> False
        Just conns -> List.any (\conn -> conn.end == endId) conns


inGraph : CotoId -> Graph -> Bool
inGraph cotoId graph =
    (graph.rootConnections |> List.any (\conn -> conn.end == cotoId))
        || (graph.connections |> Dict.member cotoId)
        || (graph.connections
            |> Dict.values
            |> List.any (\conns ->
                conns |> List.any (\conn -> conn.end == cotoId)
            )
           )


hasChildren : CotoId -> Graph -> Bool
hasChildren cotoId graph =
    graph.connections |> Dict.member cotoId


addRootConnections : List Coto -> Graph -> Graph
addRootConnections cotos model =
    List.foldr
        (\coto model ->
            addRootConnection coto model
        )
        model
        cotos


addRootConnection : Coto -> Graph -> Graph
addRootConnection coto graph =
    if pinned coto.id graph then
        graph
    else
        { graph
        | cotos = Dict.insert coto.id coto graph.cotos
        , rootConnections =
            (initConnection Nothing coto.id) :: graph.rootConnections
        }


deleteRootConnection : CotoId -> Graph -> Graph
deleteRootConnection cotoId graph =
    { graph
    | rootConnections =
        graph.rootConnections
        |> List.filter (\conn -> conn.end /= cotoId)
    }


addConnection : Coto -> Coto -> Graph -> Graph
addConnection start end graph =
    let
        cotos =
            graph.cotos
                |> Dict.insert start.id start
                |> Dict.insert end.id end

        rootConnections =
            if member start.id graph then
                graph.rootConnections
            else
                (initConnection Nothing start.id) :: graph.rootConnections

        connections =
            if connected start.id end.id graph then
                graph.connections
            else
                Dict.update
                    start.id
                    (\maybeConns ->
                        case maybeConns of
                            Nothing ->
                                Just [ (initConnection (Just start.id) end.id) ]
                            Just conns ->
                                Just ((initConnection (Just start.id) end.id) :: conns)
                    )
                    graph.connections
    in
        { graph
        | cotos = cotos
        , rootConnections = rootConnections
        , connections = connections
        }


addConnections : Coto -> (List Coto) -> Graph -> Graph
addConnections startCoto endCotos graph =
    List.foldr
        (\endCoto graph ->
            addConnection startCoto endCoto graph
        )
        graph
        endCotos


deleteConnection : ( CotoId, CotoId ) -> Graph -> Graph
deleteConnection ( fromId, toId ) graph =
    { graph
    | connections = graph.connections |> doDeleteConnection ( fromId, toId )
    }
        |> \graph ->
            { graph
            | cotos =
                -- remove the coto (toId) if it's an orphan
                if inGraph toId graph then
                    graph.cotos
                else
                    graph.cotos |> Dict.remove toId
            }

doDeleteConnection : ( CotoId, CotoId ) -> Dict.Dict CotoId (List Connection) -> Dict.Dict CotoId (List Connection)
doDeleteConnection ( fromId, toId ) connections =
    connections
    |> Dict.update
        fromId
        (\maybeChildren ->
            case maybeChildren of
                Nothing -> Nothing
                Just children ->
                    children
                        |> List.filter (\conn -> conn.end /= toId)
                        |> \children ->
                            if List.isEmpty children then
                                Nothing
                            else
                                Just children
        )


removeCoto : CotoId -> Graph -> ( Graph, List Connection )
removeCoto cotoId graph =
    let
        ( remainedRoots, removedRoots ) =
            graph.rootConnections
                |> List.partition (\conn -> conn.end /= cotoId)

        ( connectionDict1, startMissingConns ) =
            case graph.connections |> Dict.get cotoId of
                Nothing ->
                    ( graph.connections, [] )
                Just removedConns ->
                    ( Dict.remove cotoId graph.connections, removedConns )

        ( connectionDict2, endMissingConns ) =
            Dict.foldl
                (\startId children ( connDict, removedConns ) ->
                    children
                        |> List.partition (\conn -> conn.end /= cotoId)
                        |> \( remained, removed ) ->
                            ( connDict |> Dict.insert startId remained, removedConns ++ removed )
                )
                ( Dict.empty, [] )
                connectionDict1
    in
        ( { graph
          | cotos = graph.cotos |> Dict.remove cotoId
          , rootConnections = remainedRoots
          , connections = connectionDict2
          }
        , removedRoots ++ startMissingConns ++ endMissingConns
        )
