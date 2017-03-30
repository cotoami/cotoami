module Components.Connections.Model exposing (..)

import Dict
import App.Types exposing (..)


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
