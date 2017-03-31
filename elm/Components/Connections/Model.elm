module Components.Connections.Model exposing (..)

import Dict
import App.Types exposing (..)


type alias Connection =
    { id : Maybe Int
    , key : String
    , end : Int
    }


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


connectedAsRoot : Int -> Model -> Bool
connectedAsRoot cotoId model =
    List.any (\conn -> conn.end == cotoId) model.rootConnections
    

addRootConnection : Coto -> Model -> Model
addRootConnection coto model = 
    if connectedAsRoot coto.id model then
        model
    else
        { model 
        | cotos = Dict.insert coto.id coto model.cotos
        , rootConnections = 
            List.append model.rootConnections [Connection Nothing "" coto.id]
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
