module App.Types.Graph.Reorder exposing
    ( byCotoId
    , moveToFirst
    , moveToLast
    , swap
    )

import App.Types.Connection exposing (Connection)
import App.Types.Coto exposing (Coto, CotoId)
import App.Types.Graph exposing (Graph)
import List.Extra


reorder : Maybe CotoId -> (List Connection -> List Int) -> Graph -> Graph
reorder maybeParentId makeIndexOrder graph =
    graph
        |> App.Types.Graph.getOutboundConnections maybeParentId
        |> Maybe.map makeIndexOrder
        |> Maybe.map (\indexOrder -> App.Types.Graph.reorder maybeParentId indexOrder graph)
        |> Maybe.withDefault graph


byCotoId : Maybe CotoId -> List CotoId -> Graph -> Graph
byCotoId maybeParentId newOrder graph =
    reorder
        maybeParentId
        (\connections ->
            newOrder
                |> List.filterMap
                    (\cotoId ->
                        List.Extra.findIndex
                            (\conn -> conn.end == cotoId)
                            connections
                    )
        )
        graph


swap : Maybe CotoId -> Int -> Int -> Graph -> Graph
swap maybeParentId index1 index2 graph =
    reorder
        maybeParentId
        (\connections ->
            List.range 0 (List.length connections - 1)
                |> List.Extra.swapAt index1 index2
        )
        graph


moveToFirst : Maybe CotoId -> Int -> Graph -> Graph
moveToFirst maybeParentId index graph =
    reorder
        maybeParentId
        (\connections ->
            List.range 0 (List.length connections - 1)
                |> List.Extra.removeAt index
                |> (::) index
        )
        graph


moveToLast : Maybe CotoId -> Int -> Graph -> Graph
moveToLast maybeParentId index graph =
    reorder
        maybeParentId
        (\connections ->
            List.range 0 (List.length connections - 1)
                |> List.Extra.removeAt index
                |> (\indexes -> List.append indexes [ index ])
        )
        graph
