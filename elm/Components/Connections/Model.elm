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
    , connections : Dict.Dict Int Connection
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
            (Connection Nothing "" coto.id) :: model.rootConnections
        }
