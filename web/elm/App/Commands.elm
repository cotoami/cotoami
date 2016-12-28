module App.Commands exposing (..)

import Http
import Json.Decode as Decode
import App.Types exposing (Session)
import App.Messages exposing (..)


fetchSession : Cmd Msg
fetchSession =
    Http.send SessionFetched (Http.get "/api/session" decodeSession)
    

decodeSession : Decode.Decoder Session
decodeSession =
    Decode.map4 Session
        (Decode.field "id" Decode.int)
        (Decode.field "email" Decode.string)
        (Decode.field "avatar_url" Decode.string)
        (Decode.field "display_name" Decode.string)
