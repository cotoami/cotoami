module App.Server.Session exposing (..)

import Http
import Json.Decode as Decode
import App.Messages exposing (Msg(..))
import App.Types.Session exposing (Session)


decodeSession : Decode.Decoder Session
decodeSession =
    Decode.map8 Session
        (Decode.field "token" Decode.string)
        (Decode.field "websocket_url" Decode.string)
        (Decode.field "id" Decode.string)
        (Decode.field "email" Decode.string)
        (Decode.field "owner" Decode.bool)
        (Decode.field "avatar_url" Decode.string)
        (Decode.field "display_name" Decode.string)
        (Decode.field "lang" Decode.string)


fetchSession : Cmd Msg
fetchSession =
    Http.send SessionFetched (Http.get "/api/public/session" decodeSession)


type alias SessionNotFoundBody =
    { signupEnabled : Bool
    }


defaultSessionNotFoundBody : SessionNotFoundBody
defaultSessionNotFoundBody =
    { signupEnabled = False
    }


decodeSessionNotFoundBody : Decode.Decoder SessionNotFoundBody
decodeSessionNotFoundBody =
    Decode.map SessionNotFoundBody
        (Decode.field "signup_enabled" Decode.bool)


decodeSessionNotFoundBodyString : String -> SessionNotFoundBody
decodeSessionNotFoundBodyString body =
    let
        decodeResult =
            Decode.decodeString decodeSessionNotFoundBody body
    in
        case decodeResult of
            Ok body ->
                body

            Err _ ->
                defaultSessionNotFoundBody
