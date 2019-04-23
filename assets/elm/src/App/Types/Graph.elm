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
    , hasSubgraphLoaded
    , hasSubgraphLoading
    , hasSubgraphsLoading
    , incrementIncoming
    , incrementOutgoing
    , initGraph
    , member
    , mergeSubgraph
    , pinned
    , reachableFromPins
    , removeCoto
    , reorder
    , setLinkingPhrase
    , setSubgraphLoading
    , update
    , updateCotoContent
    )

import App.Types.Connection exposing (Connection, Direction(..))
import App.Types.Coto exposing (Coto, CotoId, Cotonoma, CotonomaKey, ElementId)
import Dict exposing (Dict)
import List.Extra
import Maybe exposing (withDefault)
import Set exposing (Set)


type alias CotoDict =
    Dict CotoId Coto


incrementOutgoing : Coto -> CotoDict -> CotoDict
incrementOutgoing coto cotoDict =
    cotoDict
        |> Dict.insert coto.id
            (cotoDict
                |> Dict.get coto.id
                |> Maybe.withDefault coto
                |> App.Types.Coto.incrementOutgoing
            )


incrementIncoming : Coto -> CotoDict -> CotoDict
incrementIncoming coto cotoDict =
    cotoDict
        |> Dict.insert coto.id
            (cotoDict
                |> Dict.get coto.id
                |> Maybe.withDefault coto
                |> App.Types.Coto.incrementIncoming
            )


type alias ConnectionDict =
    Dict CotoId (List Connection)


type alias Graph =
    { cotos : CotoDict
    , rootConnections : List Connection
    , connections : ConnectionDict
    , reachableCotoIds : Set CotoId
    , loadedSubgraphs : Set CotonomaKey
    , loadingSubgraphs : Set CotonomaKey
    }


defaultGraph : Graph
defaultGraph =
    { cotos = Dict.empty
    , rootConnections = []
    , connections = Dict.empty
    , reachableCotoIds = Set.empty
    , loadedSubgraphs = Set.empty
    , loadingSubgraphs = Set.empty
    }


initGraph : Dict CotoId Coto -> List Connection -> ConnectionDict -> Graph
initGraph cotos rootConnections connections =
    defaultGraph |> update cotos rootConnections connections


update : CotoDict -> List Connection -> ConnectionDict -> Graph -> Graph
update cotos rootConnections connections graph =
    { graph
        | cotos = cotos
        , rootConnections = rootConnections
        , connections = connections
    }
        |> updateReachableCotoIds


setSubgraphLoading : CotonomaKey -> Graph -> Graph
setSubgraphLoading cotonomaKey graph =
    { graph | loadingSubgraphs = Set.insert cotonomaKey graph.loadingSubgraphs }


hasSubgraphsLoading : Graph -> Bool
hasSubgraphsLoading graph =
    not (Set.isEmpty graph.loadingSubgraphs)


hasSubgraphLoading : CotonomaKey -> Graph -> Bool
hasSubgraphLoading cotonomaKey graph =
    Set.member cotonomaKey graph.loadingSubgraphs


mergeSubgraph : CotonomaKey -> Graph -> Graph -> Graph
mergeSubgraph cotonomaKey subgraph graph =
    graph
        |> update
            (Dict.union subgraph.cotos graph.cotos)
            graph.rootConnections
            (Dict.union subgraph.connections graph.connections)
        |> setSubgraphLoaded cotonomaKey


setSubgraphLoaded : CotonomaKey -> Graph -> Graph
setSubgraphLoaded cotonomaKey graph =
    { graph
        | loadedSubgraphs = Set.insert cotonomaKey graph.loadedSubgraphs
        , loadingSubgraphs = Set.remove cotonomaKey graph.loadingSubgraphs
    }


hasSubgraphLoaded : CotonomaKey -> Graph -> Bool
hasSubgraphLoaded cotonomaKey graph =
    Set.member cotonomaKey graph.loadedSubgraphs


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


reachableFromPins : CotoId -> Graph -> Bool
reachableFromPins cotoId graph =
    Set.member cotoId graph.reachableCotoIds


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
    maybeCotoId
        |> Maybe.map (\cotoId -> Dict.get cotoId graph.connections)
        |> Maybe.withDefault (Just graph.rootConnections)
        |> Maybe.map List.reverse


addCoto : Coto -> Graph -> Graph
addCoto coto graph =
    { graph | cotos = Dict.insert coto.id coto graph.cotos }


updateCoto : CotoId -> (Coto -> Coto) -> Graph -> Graph
updateCoto cotoId update graph =
    { graph | cotos = Dict.update cotoId (Maybe.map update) graph.cotos }


updateCotoContent : Coto -> Graph -> Graph
updateCotoContent coto graph =
    updateCoto
        coto.id
        (\targetCoto ->
            { targetCoto
                | content = coto.content
                , summary = coto.summary
                , asCotonoma = coto.asCotonoma
            }
        )
        graph


cotonomatize : Cotonoma -> CotoId -> Graph -> Graph
cotonomatize cotonoma cotoId graph =
    graph
        |> updateCoto cotoId
            (\targetCoto -> { targetCoto | asCotonoma = Just cotonoma })
        |> setSubgraphLoaded cotonoma.key


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
    graph
        |> update
            (Dict.remove cotoId graph.cotos)
            rootConnections
            connections


reorder : Maybe CotoId -> List Int -> Graph -> Graph
reorder maybeParentId indexOrder graph =
    maybeParentId
        |> Maybe.map
            (\parentId ->
                graph.connections
                    |> Dict.update parentId (Maybe.map (reorderConnections indexOrder))
                    |> (\connections -> { graph | connections = connections })
            )
        |> Maybe.withDefault
            (graph.rootConnections
                |> reorderConnections indexOrder
                |> (\connections -> { graph | rootConnections = connections })
            )


reorderConnections : List Int -> List Connection -> List Connection
reorderConnections indexOrder connections =
    connections
        |> List.reverse
        |> reorderConnectionsInDisplayOrder indexOrder
        |> List.reverse


reorderConnectionsInDisplayOrder : List Int -> List Connection -> List Connection
reorderConnectionsInDisplayOrder indexOrder connections =
    if
        sameLength indexOrder connections
            && List.Extra.allDifferent indexOrder
    then
        let
            orderedConnections =
                List.filterMap
                    (\index -> List.Extra.getAt index connections)
                    indexOrder
        in
        if sameLength orderedConnections connections then
            orderedConnections

        else
            connections

    else
        connections


sameLength : List a -> List b -> Bool
sameLength listA listB =
    List.length listA == List.length listB


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


setLinkingPhrase : Maybe Cotonoma -> CotoId -> CotoId -> Maybe String -> Graph -> Graph
setLinkingPhrase currentCotonoma startId endId linkingPhrase graph =
    let
        setLinkingPhraseByEndId =
            List.Extra.updateIf
                (\conn -> conn.end == endId)
                (App.Types.Connection.setLinkingPhrase linkingPhrase)
    in
    if Just startId == Maybe.map .cotoId currentCotonoma then
        let
            rootConnections =
                setLinkingPhraseByEndId graph.rootConnections
        in
        { graph | rootConnections = rootConnections }

    else
        let
            connections =
                graph.connections
                    |> Dict.update startId (Maybe.map setLinkingPhraseByEndId)
        in
        { graph | connections = connections }
