module App.Types.Graph exposing (..)

import Dict
import Maybe exposing (withDefault)
import List.Extra
import App.Types.Amishi exposing (AmishiId)
import App.Types.Session exposing (Session)
import App.Types.Coto exposing (Coto, CotoId, CotonomaKey)


type Direction
    = Outbound
    | Inbound


type alias Connection =
    { key : String
    , amishiId : AmishiId
    , start : Maybe CotoId
    , end : CotoId
    }


initConnection : AmishiId -> Maybe CotoId -> CotoId -> Connection
initConnection amishiId maybeStart end =
    let
        key =
            (withDefault "root" maybeStart) ++ " -> " ++ end
    in
        Connection key amishiId maybeStart end


type alias ConnectionDict =
    Dict.Dict CotoId (List Connection)


type alias Graph =
    { cotos : Dict.Dict CotoId Coto
    , rootConnections : List Connection
    , connections : ConnectionDict
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


updateCoto : CotoId -> (Coto -> Coto) -> Graph -> Graph
updateCoto cotoId update graph =
    { graph | cotos = Dict.update cotoId (Maybe.map update) graph.cotos }


updateContent : Coto -> Graph -> Graph
updateContent coto graph =
    updateCoto
        coto.id
        (\currentCoto ->
            { currentCoto
                | content = coto.content
                , summary = coto.summary
            }
        )
        graph


cotonomatize : CotoId -> CotonomaKey -> Graph -> Graph
cotonomatize cotoId cotonomaKey graph =
    updateCoto
        cotoId
        (\coto ->
            { coto
                | asCotonoma = True
                , cotonomaKey = Just cotonomaKey
            }
        )
        graph


connected : CotoId -> CotoId -> Graph -> Bool
connected startId endId graph =
    case Dict.get startId graph.connections of
        Nothing ->
            False

        Just conns ->
            List.any (\conn -> conn.end == endId) conns


inGraph : CotoId -> Graph -> Bool
inGraph cotoId graph =
    (graph.rootConnections |> List.any (\conn -> conn.end == cotoId))
        || (graph.connections |> Dict.member cotoId)
        || (graph.connections
                |> Dict.values
                |> List.any
                    (\conns ->
                        conns |> List.any (\conn -> conn.end == cotoId)
                    )
           )


getParents : CotoId -> Graph -> List Coto
getParents cotoId graph =
    List.filterMap
        (\parentId ->
            graph.connections
                |> Dict.get parentId
                |> Maybe.andThen (List.Extra.find (\c -> c.end == cotoId))
                |> Maybe.andThen (\_ -> getCoto parentId graph)
        )
        (Dict.keys graph.connections)


hasChildren : CotoId -> Graph -> Bool
hasChildren cotoId graph =
    graph.connections |> Dict.member cotoId


pinCoto : Session -> Coto -> Graph -> Graph
pinCoto session coto graph =
    if pinned coto.id graph then
        graph
    else
        { graph
            | cotos = Dict.insert coto.id coto graph.cotos
            , rootConnections =
                (initConnection session.id Nothing coto.id) :: graph.rootConnections
        }


unpinCoto : CotoId -> Graph -> Graph
unpinCoto cotoId graph =
    { graph
        | rootConnections =
            graph.rootConnections
                |> List.filter (\conn -> conn.end /= cotoId)
    }


connect : Session -> Coto -> Coto -> Graph -> Graph
connect session start end graph =
    let
        cotos =
            graph.cotos
                |> Dict.insert start.id start
                |> Dict.insert end.id end

        newConnection =
            initConnection session.id (Just start.id) end.id

        connections =
            if connected start.id end.id graph then
                graph.connections
            else
                Dict.update
                    start.id
                    (\maybeConns ->
                        maybeConns
                            |> Maybe.map ((::) newConnection)
                            |> Maybe.withDefault [ newConnection ]
                            |> Just
                    )
                    graph.connections
    in
        { graph | cotos = cotos, connections = connections }


connectOneToMany : Session -> Coto -> List Coto -> Graph -> Graph
connectOneToMany session startCoto endCotos graph =
    List.foldr
        (\endCoto graph ->
            connect session startCoto endCoto graph
        )
        graph
        endCotos


connectManyToOne : Session -> List Coto -> Coto -> Graph -> Graph
connectManyToOne session startCotos endCoto graph =
    List.foldr
        (\startCoto graph ->
            connect session startCoto endCoto graph
        )
        graph
        startCotos


batchConnect : Session -> Direction -> List Coto -> Coto -> Graph -> Graph
batchConnect session direction objects subject graph =
    case direction of
        Outbound ->
            connectOneToMany session subject objects graph

        Inbound ->
            connectManyToOne session objects subject graph


disconnect : ( CotoId, CotoId ) -> Graph -> Graph
disconnect ( fromId, toId ) graph =
    { graph
        | connections = deleteConnection ( fromId, toId ) graph.connections
    }


deleteConnection : ( CotoId, CotoId ) -> ConnectionDict -> ConnectionDict
deleteConnection ( fromId, toId ) connections =
    connections
        |> Dict.update
            fromId
            (\maybeConns ->
                maybeConns
                    |> Maybe.map (List.filter (\conn -> conn.end /= toId))
                    |> Maybe.andThen
                        (\conns ->
                            if List.isEmpty conns then
                                Nothing
                            else
                                Just conns
                        )
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
