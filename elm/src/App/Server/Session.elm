module App.Server.Session exposing (..)

import Http
import Json.Decode as Decode
import App.Messages exposing (Msg(..))
import App.Types.Session exposing(Session)


decodeSession : Decode.Decoder Session
decodeSession =
    Decode.map7 Session
        (Decode.field "token" Decode.string)
        (Decode.field "websocket_url" Decode.string)
        (Decode.field "id" Decode.string)
        (Decode.field "email" Decode.string)
        (Decode.field "owner" Decode.bool)
        (Decode.field "avatar_url" Decode.string)
        (Decode.field "display_name" Decode.string)


fetchSession : Cmd Msg
fetchSession =
    Http.send SessionFetched (Http.get "/api/public/session" decodeSession)
