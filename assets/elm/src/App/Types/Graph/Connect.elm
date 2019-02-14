module App.Types.Graph.Connect exposing
    ( batch
    , connect
    , disconnect
    , pin
    , unpin
    )

import App.Types.Amishi exposing (AmishiId)
import App.Types.Connection exposing (Direction(..))
import App.Types.Coto exposing (Coto, CotoId)
import App.Types.Graph exposing (ConnectionDict, CotoDict, Graph)
import Dict


pin : AmishiId -> Coto -> Graph -> Graph
pin amishiId coto graph =
    if App.Types.Graph.pinned coto.id graph then
        graph

    else
        let
            cotos =
                Dict.insert coto.id coto graph.cotos

            rootConnections =
                { start = Nothing
                , end = coto.id
                , linkingPhrase = Nothing
                , amishiId = amishiId
                }
                    :: graph.rootConnections
        in
        graph |> App.Types.Graph.update cotos rootConnections graph.connections


unpin : CotoId -> Graph -> Graph
unpin cotoId graph =
    let
        rootConnections =
            graph.rootConnections
                |> List.filter (\conn -> conn.end /= cotoId)
    in
    graph |> App.Types.Graph.update graph.cotos rootConnections graph.connections


connect : AmishiId -> Coto -> Coto -> Graph -> Graph
connect amishiId start end graph =
    batch amishiId Outbound [ end ] start graph


batch : AmishiId -> Direction -> List Coto -> Coto -> Graph -> Graph
batch amishiId direction cotos subject graph =
    case direction of
        Outbound ->
            connectOneToMany amishiId subject cotos graph

        Inbound ->
            connectManyToOne amishiId cotos subject graph


connectOneToMany : AmishiId -> Coto -> List Coto -> Graph -> Graph
connectOneToMany amishiId startCoto endCotos graph =
    endCotos
        |> List.foldl
            (singleConnect graph amishiId startCoto)
            ( graph.cotos, graph.connections )
        |> (\( cotos, connections ) ->
                graph |> App.Types.Graph.update cotos graph.rootConnections connections
           )


connectManyToOne : AmishiId -> List Coto -> Coto -> Graph -> Graph
connectManyToOne amishiId startCotos endCoto graph =
    startCotos
        |> List.foldl
            (\startCoto state ->
                singleConnect graph amishiId startCoto endCoto state
            )
            ( graph.cotos, graph.connections )
        |> (\( cotos, connections ) ->
                graph |> App.Types.Graph.update cotos graph.rootConnections connections
           )


type alias ConnectingState =
    ( CotoDict, ConnectionDict )


singleConnect : Graph -> AmishiId -> Coto -> Coto -> ConnectingState -> ConnectingState
singleConnect graph amishiId start end (( cotos, connections ) as state) =
    if App.Types.Graph.connected start.id end.id graph then
        state

    else
        let
            newConnection =
                { start = Just start.id
                , end = end.id
                , linkingPhrase = Nothing
                , amishiId = amishiId
                }
        in
        ( cotos
            |> Dict.insert start.id start
            |> Dict.insert end.id end
        , Dict.update
            start.id
            (\maybeConns ->
                maybeConns
                    |> Maybe.map ((::) newConnection)
                    |> Maybe.withDefault [ newConnection ]
                    |> Just
            )
            connections
        )


disconnect : ( CotoId, CotoId ) -> Graph -> Graph
disconnect ( fromId, toId ) graph =
    let
        connections =
            Dict.update
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
                graph.connections
    in
    graph |> App.Types.Graph.update graph.cotos graph.rootConnections connections
