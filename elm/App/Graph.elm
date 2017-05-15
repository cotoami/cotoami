module App.Graph exposing (..)

import Dict
import App.Types exposing (..)


type alias Connection =
    { key : String
    , end : CotoId
    }
    
    
initConnection : Maybe CotoId -> CotoId -> Connection
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


type alias Graph =
    { cotos : Dict.Dict CotoId Coto
    , rootConnections : List Connection
    , connections : Dict.Dict CotoId (List Connection)
    }


initGraph : Graph
initGraph =
    { cotos = Dict.empty
    , rootConnections = []
    , connections = Dict.empty
    }


pinned : CotoId -> Graph -> Bool
pinned cotoId graph =
    List.any (\conn -> conn.end == cotoId) graph.rootConnections
  

member : CotoId -> Graph -> Bool
member cotoId graph =
    graph.cotos |> Dict.member cotoId
    
    
connected : CotoId -> CotoId -> Graph -> Bool
connected startId endId graph =
    case Dict.get startId graph.connections of
        Nothing -> False
        Just conns -> List.any (\conn -> conn.end == endId) conns
        
    
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


getTraversalStarts : Graph -> List ( Coto, List Connection )
getTraversalStarts graph =
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
        
    
type alias Traversal =
    { start : CotoId
    , steps : List CotoId
    }


type alias Traverse =
    { traversal : Traversal
    , startIndex : Int
    , endCotoId : CotoId
    }                


initTraversal : CotoId -> Maybe CotoId -> Traversal
initTraversal start maybeNext =
    { start = start
    , steps = 
        case maybeNext of
            Nothing -> []
            Just next -> [ next ]
    }


doTraverse : Traverse -> Traversal
doTraverse traverse =
    let
        traversal = traverse.traversal
        stepsCount = List.length traversal.steps
    in
        { traversal
        | steps = 
            traversal.steps
            |> List.drop (stepsCount - (traverse.startIndex + 1))
            |> (::) traverse.endCotoId
        }


traversed : Int -> CotoId -> Traversal -> Bool
traversed index cotoId traversal =
    let
        steps = 
          if index < 0 then
              traversal.steps |> List.reverse 
          else
              traversal.steps |> List.reverse |> List.drop (index + 1)
          
    in  
        case List.head steps of
            Nothing -> False
            Just nextStep -> nextStep == cotoId
            
