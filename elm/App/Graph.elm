module App.Graph exposing (..)

import Dict
import App.Types exposing (..)


type alias Connection =
    { key : String
    , end : Int
    }


type alias Graph =
    { cotos : Dict.Dict Int Coto
    , rootConnections : List Connection
    , connections : Dict.Dict Int (List Connection)
    }
    
    
initConnection : Maybe Int -> Int -> Connection
initConnection maybeStart end =
    let
        startLabel =
            case maybeStart of
                Nothing -> "root"
                Just start -> toString start
        endLabel = toString end
    in
        Connection 
            ("connection-" ++ startLabel ++ "-" ++ endLabel)
            end


initGraph : Graph
initGraph =
    { cotos = Dict.empty
    , rootConnections = []
    , connections = Dict.empty
    }


pinned : Int -> Graph -> Bool
pinned cotoId graph =
    List.any (\conn -> conn.end == cotoId) graph.rootConnections
  

connected : Int -> Graph -> Bool
connected cotoId graph =
    graph.cotos |> Dict.member cotoId
    
    
hasChildren : Int -> Graph -> Bool
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


getSecondConnections : Graph -> List ( Coto, List Connection )
getSecondConnections graph =
    List.filterMap 
        (\conn ->
            case Dict.get conn.end graph.cotos of
                Nothing -> Nothing
                Just rootCoto ->
                    case Dict.get rootCoto.id graph.connections of
                        Nothing -> Nothing
                        Just connections -> Just ( rootCoto, connections )
                      
        ) 
        graph.rootConnections


addConnection : Coto -> Coto -> Graph -> Graph
addConnection start end graph =
    let
        cotos = 
            graph.cotos 
                |> Dict.insert start.id start 
                |> Dict.insert end.id end 
            
        rootConnections = 
            if connected start.id graph then
                graph.rootConnections
            else
                (initConnection Nothing start.id) :: graph.rootConnections
                
        connections =
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
        
      
