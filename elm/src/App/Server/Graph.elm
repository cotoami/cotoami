module App.Server.Graph exposing (..)

import Json.Decode as Decode
import App.Types.Graph exposing (Connection, initConnection)


decodeConnection : Decode.Decoder Connection
decodeConnection =
    Decode.map2 initConnection
        (Decode.maybe (Decode.field "start" Decode.string))
        (Decode.field "end" Decode.string)
