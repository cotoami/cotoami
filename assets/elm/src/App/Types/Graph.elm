module App.Types.Graph exposing (..)

import Dict exposing (Dict)
import Set exposing (Set)
import Maybe exposing (withDefault)
import List.Extra
import Exts.Maybe exposing (isJust)
import App.Types.Amishi exposing (AmishiId)
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
    Dict CotoId (List Connection)


type alias Graph =
    { cotos : Dict CotoId Coto
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


getOutboundConnections : Maybe CotoId -> Graph -> Maybe (List Connection)
getOutboundConnections maybeCotoId graph =
    if isJust maybeCotoId then
        maybeCotoId
            |> Maybe.andThen (\cotoId -> Dict.get cotoId graph.connections)
    else
        Just graph.rootConnections


pinCoto : AmishiId -> Coto -> Graph -> Graph
pinCoto amishiId coto graph =
    if pinned coto.id graph then
        graph
    else
        { graph
            | cotos = Dict.insert coto.id coto graph.cotos
            , rootConnections =
                (initConnection amishiId Nothing coto.id) :: graph.rootConnections
        }


unpinCoto : CotoId -> Graph -> Graph
unpinCoto cotoId graph =
    { graph
        | rootConnections =
            graph.rootConnections
                |> List.filter (\conn -> conn.end /= cotoId)
    }


connect : AmishiId -> Coto -> Coto -> Graph -> Graph
connect amishiId start end graph =
    let
        cotos =
            graph.cotos
                |> Dict.insert start.id start
                |> Dict.insert end.id end

        newConnection =
            initConnection amishiId (Just start.id) end.id

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


connectOneToMany : AmishiId -> Coto -> List Coto -> Graph -> Graph
connectOneToMany amishiId startCoto endCotos graph =
    List.foldr
        (\endCoto graph ->
            connect amishiId startCoto endCoto graph
        )
        graph
        endCotos


connectManyToOne : AmishiId -> List Coto -> Coto -> Graph -> Graph
connectManyToOne amishiId startCotos endCoto graph =
    List.foldr
        (\startCoto graph ->
            connect amishiId startCoto endCoto graph
        )
        graph
        startCotos


batchConnect : AmishiId -> Direction -> List Coto -> Coto -> Graph -> Graph
batchConnect amishiId direction cotos target graph =
    case direction of
        Outbound ->
            connectOneToMany amishiId target cotos graph

        Inbound ->
            connectManyToOne amishiId cotos target graph


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


updateConnections : Maybe CotoId -> (List Connection -> List Connection) -> Graph -> Graph
updateConnections maybeParentId update graph =
    maybeParentId
        |> Maybe.map
            (\parentId ->
                graph.connections
                    |> Dict.update parentId (Maybe.map update)
                    |> (\connections -> { graph | connections = connections })
            )
        |> Maybe.withDefault
            (graph.rootConnections
                |> update
                |> (\connections -> { graph | rootConnections = connections })
            )


swapOrder : Maybe CotoId -> Int -> Int -> Graph -> Graph
swapOrder maybeParentId index1 index2 graph =
    updateConnections
        maybeParentId
        (\connections ->
            connections
                |> List.reverse
                |> List.Extra.swapAt index1 index2
                |> List.reverse
        )
        graph


moveToFirst : Maybe CotoId -> Int -> Graph -> Graph
moveToFirst maybeParentId index graph =
    updateConnections
        maybeParentId
        (\connections ->
            let
                connectionsInDisplayOrder =
                    List.reverse connections
            in
                connectionsInDisplayOrder
                    |> List.Extra.getAt index
                    |> Maybe.map
                        (\conn ->
                            connectionsInDisplayOrder
                                |> List.Extra.removeAt index
                                |> (::) conn
                                |> List.reverse
                        )
                    |> Maybe.withDefault connections
        )
        graph


moveToLast : Maybe CotoId -> Int -> Graph -> Graph
moveToLast maybeParentId index graph =
    updateConnections
        maybeParentId
        (\connections ->
            let
                connectionsInDisplayOrder =
                    List.reverse connections
            in
                connectionsInDisplayOrder
                    |> List.Extra.getAt index
                    |> Maybe.map
                        (\conn ->
                            connectionsInDisplayOrder
                                |> List.Extra.removeAt index
                                |> List.reverse
                                |> (::) conn
                        )
                    |> Maybe.withDefault connections
        )
        graph


reorder : Maybe CotoId -> List CotoId -> Graph -> Graph
reorder maybeParentId newOrder graph =
    updateConnections
        maybeParentId
        (\connections ->
            newOrder
                |> List.reverse
                |> List.filterMap
                    (\cotoId ->
                        List.Extra.find
                            (\conn -> conn.end == cotoId)
                            connections
                    )
        )
        graph


collectReachableCotoIds : Set CotoId -> Graph -> Set CotoId -> Set CotoId
collectReachableCotoIds sourceIds graph collectedIds =
    let
        unexploredSourceIds =
            Set.diff sourceIds collectedIds

        nextCotoIds =
            unexploredSourceIds
                |> Set.toList
                |> List.map
                    (\cotoId ->
                        graph.connections
                            |> Dict.get cotoId
                            |> Maybe.map (List.map (\conn -> conn.end))
                            |> Maybe.withDefault []
                    )
                |> List.concat
                |> Set.fromList

        updatedCollectedIds =
            Set.union collectedIds unexploredSourceIds
    in
        if Set.isEmpty nextCotoIds then
            updatedCollectedIds
        else
            collectReachableCotoIds nextCotoIds graph updatedCollectedIds


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


excludeUnreachables : Graph -> Graph
excludeUnreachables graph =
    let
        pinnedCotoIds =
            graph.rootConnections
                |> List.map (\conn -> conn.end)
                |> Set.fromList

        reachableIds =
            collectReachableCotoIds pinnedCotoIds graph Set.empty

        reachableCotos =
            graph.cotos
                |> Dict.filter (\cotoId coto -> Set.member cotoId reachableIds)
    in
        { graph | cotos = reachableCotos }
            |> deleteInvalidConnections


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


type PinnedCotosView
    = DocumentView
    | GraphView
