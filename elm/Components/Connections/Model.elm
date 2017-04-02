module Components.Connections.Model exposing (..)

import Dict
import App.Types exposing (..)


type alias Connection =
    { key : String
    , end : Int
    }
    
    
newConnection : Maybe Int -> Int -> Connection
newConnection maybeStart end =
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


type alias Model =
    { cotos : Dict.Dict Int Coto
    , rootConnections : List Connection
    , connections : Dict.Dict Int (List Connection)
    }


initModel : Model
initModel =
    { cotos = Dict.empty
    , rootConnections = []
    , connections = Dict.empty
    }


connected : Int -> Model -> Bool
connected cotoId model =
    model.cotos |> Dict.member cotoId
    

connectedAsRoot : Int -> Model -> Bool
connectedAsRoot cotoId model =
    List.any (\conn -> conn.end == cotoId) model.rootConnections
    

addRootConnections : List Coto -> Model -> Model
addRootConnections cotos model =
    List.foldr 
        (\coto model ->
            addRootConnection coto model
        ) 
        model 
        cotos
        

addRootConnection : Coto -> Model -> Model
addRootConnection coto model = 
    if connectedAsRoot coto.id model then
        model
    else
        { model 
        | cotos = Dict.insert coto.id coto model.cotos
        , rootConnections = 
            (newConnection Nothing coto.id) :: model.rootConnections
        }


getSecondConnections : Model -> List ( Coto, List Connection )
getSecondConnections model =
    List.filterMap 
        (\conn ->
            case Dict.get conn.end model.cotos of
                Nothing -> Nothing
                Just rootCoto ->
                    case Dict.get rootCoto.id model.connections of
                        Nothing -> Nothing
                        Just connections -> Just ( rootCoto, connections )
                      
        ) 
        model.rootConnections


addConnection : Coto -> Coto -> Bool -> Model -> Model
addConnection baseCoto targetCoto reverse model =
    let
        cotos = 
            model.cotos 
                |> Dict.insert baseCoto.id baseCoto 
                |> Dict.insert targetCoto.id targetCoto 
            
        ( from, to ) = 
            if reverse then 
                ( targetCoto, baseCoto ) 
            else 
                ( baseCoto, targetCoto )
        
        rootConnections = 
            if connected from.id model then
                model.rootConnections
            else
                (newConnection Nothing from.id) :: model.rootConnections
                
        connections =
            Dict.update
                from.id
                (\maybeConns ->
                    case maybeConns of
                        Nothing ->
                            Just [ (newConnection (Just from.id) to.id) ]
                        Just conns ->
                            Just ((newConnection (Just from.id) to.id) :: conns)
                )
                model.connections
    in
        { model
        | cotos = cotos
        , rootConnections = rootConnections
        , connections = connections
        }
        

addConnections : Coto -> (List Coto) -> Bool -> Model -> Model
addConnections baseCoto targetCotos reverse model =
    List.foldr 
        (\targetCoto model ->
            addConnection baseCoto targetCoto reverse model
        ) 
        model 
        targetCotos
        
      
