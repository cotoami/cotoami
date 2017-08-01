module App.Server.Session exposing (..)

import Http
import Json.Decode as Decode
import App.Types.Session exposing(Session)
import App.Messages exposing (Msg(..))


decodeSession : Decode.Decoder Session
decodeSession =
    Decode.map6 Session
        (Decode.field "token" Decode.string)
        (Decode.field "websocket_url" Decode.string)
        (Decode.field "id" Decode.string)
        (Decode.field "email" Decode.string)
        (Decode.field "avatar_url" Decode.string)
        (Decode.field "display_name" Decode.string)


fetchSession : Cmd Msg
fetchSession =
    Http.send SessionFetched (Http.get "/api/session" decodeSession)
