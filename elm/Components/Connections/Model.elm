module Components.Connections.Model exposing (..)

import Dict
import App.Types exposing (..)


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


addConnection : Coto -> Coto -> Model -> Model
addConnection start end model =
    let
        cotos = 
            model.cotos 
                |> Dict.insert start.id start 
                |> Dict.insert end.id end 
            
        rootConnections = 
            if connected start.id model then
                model.rootConnections
            else
                (newConnection Nothing start.id) :: model.rootConnections
                
        connections =
            Dict.update
                start.id
                (\maybeConns ->
                    case maybeConns of
                        Nothing ->
                            Just [ (newConnection (Just start.id) end.id) ]
                        Just conns ->
                            Just ((newConnection (Just start.id) end.id) :: conns)
                )
                model.connections
    in
        { model
        | cotos = cotos
        , rootConnections = rootConnections
        , connections = connections
        }
        

addConnections : Coto -> (List Coto) -> Model -> Model
addConnections startCoto endCotos model =
    List.foldr 
        (\endCoto model ->
            addConnection startCoto endCoto model
        ) 
        model 
        endCotos
        
      
