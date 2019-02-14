module App.Types.Graph exposing
    ( ConnectionDict
    , CotoDict
    , Graph
    , addCoto
    , connected
    , cotonomatize
    , defaultGraph
    , getCoto
    , getOutboundConnections
    , getParents
    , hasChildren
    , initGraph
    , member
    , mergeSubgraph
    , moveToFirst
    , moveToLast
    , pinned
    , removeCoto
    , reorder
    , swapOrder
    , toTopicGraph
    , update
    , updateCoto
    )

import App.Types.Connection exposing (Connection, Direction(..))
import App.Types.Coto exposing (Coto, CotoId, Cotonoma, CotonomaKey, ElementId)
import Dict exposing (Dict)
import Exts.Maybe exposing (isJust)
import List.Extra
import Maybe exposing (withDefault)
import Set exposing (Set)


type alias CotoDict =
    Dict CotoId Coto


type alias ConnectionDict =
    Dict CotoId (List Connection)


type alias Graph =
    { cotos : CotoDict
    , rootConnections : List Connection
    , connections : ConnectionDict
    , reachableCotoIds : Set CotoId
    }


defaultGraph : Graph
defaultGraph =
    { cotos = Dict.empty
    , rootConnections = []
    , connections = Dict.empty
    , reachableCotoIds = Set.empty
    }


update : CotoDict -> List Connection -> ConnectionDict -> Graph -> Graph
update cotos rootConnections connections graph =
    { graph
        | cotos = cotos
        , rootConnections = rootConnections
        , connections = connections
    }
        |> updateReachableCotoIds


initGraph : Dict CotoId Coto -> List Connection -> ConnectionDict -> Graph
initGraph cotos rootConnections connections =
    defaultGraph |> update cotos rootConnections connections


mergeSubgraph : Graph -> Graph -> Graph
mergeSubgraph subgraph graph =
    graph
        |> update
            (Dict.union subgraph.cotos graph.cotos)
            graph.rootConnections
            (Dict.union subgraph.connections graph.connections)


pinned : CotoId -> Graph -> Bool
pinned cotoId graph =
    List.any (\conn -> conn.end == cotoId) graph.rootConnections


member : CotoId -> Graph -> Bool
member cotoId graph =
    Dict.member cotoId graph.cotos


connected : CotoId -> CotoId -> Graph -> Bool
connected startId endId graph =
    graph.connections
        |> Dict.get startId
        |> Maybe.map (List.any (\conn -> conn.end == endId))
        |> Maybe.withDefault False


hasChildren : CotoId -> Graph -> Bool
hasChildren cotoId graph =
    graph.connections |> Dict.member cotoId


getCoto : CotoId -> Graph -> Maybe Coto
getCoto cotoId graph =
    Dict.get cotoId graph.cotos


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


getOutboundConnections : Maybe CotoId -> Graph -> Maybe (List Connection)
getOutboundConnections maybeCotoId graph =
    if isJust maybeCotoId then
        maybeCotoId
            |> Maybe.andThen (\cotoId -> Dict.get cotoId graph.connections)

    else
        Just graph.rootConnections


addCoto : Coto -> Graph -> Graph
addCoto coto graph =
    { graph | cotos = Dict.insert coto.id coto graph.cotos }


updateCoto_ : CotoId -> (Coto -> Coto) -> Graph -> Graph
updateCoto_ cotoId update graph =
    { graph | cotos = Dict.update cotoId (Maybe.map update) graph.cotos }


updateCoto : Coto -> Graph -> Graph
updateCoto coto graph =
    updateCoto_
        coto.id
        (\currentCoto ->
            { currentCoto
                | content = coto.content
                , summary = coto.summary
                , asCotonoma = coto.asCotonoma
            }
        )
        graph


cotonomatize : Cotonoma -> CotoId -> Graph -> Graph
cotonomatize cotonoma cotoId graph =
    updateCoto_ cotoId (\coto -> { coto | asCotonoma = Just cotonoma }) graph


removeCoto : CotoId -> Graph -> Graph
removeCoto cotoId graph =
    let
        rootConnections =
            graph.rootConnections
                |> List.filter (\conn -> conn.end /= cotoId)

        connections =
            graph.connections
                |> Dict.remove cotoId
                |> Dict.map
                    (\startId children ->
                        List.filter (\conn -> conn.end /= cotoId) children
                    )
    in
    { graph
        | cotos = graph.cotos |> Dict.remove cotoId
        , rootConnections = rootConnections
        , connections = connections
    }
        |> updateReachableCotoIds


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


updateReachableCotoIds : Graph -> Graph
updateReachableCotoIds graph =
    let
        pinnedCotoIds =
            graph.rootConnections
                |> List.map (\conn -> conn.end)
                |> Set.fromList

        reachableCotoIds =
            collectReachableCotoIds pinnedCotoIds graph Set.empty
    in
    { graph | reachableCotoIds = reachableCotoIds }


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
