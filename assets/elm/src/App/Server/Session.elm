module App.Server.Session
    exposing
        ( decodeSession
        , fetchSession
        , decodeAuthSettingsString
        )

import Http
import Json.Decode as Decode exposing (bool, string, list)
import App.Messages exposing (Msg(..))
import App.Types.Session exposing (Session, AuthSettings)


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


decodeAuthSettings : Decode.Decoder AuthSettings
decodeAuthSettings =
    Decode.map2 AuthSettings
        (Decode.field "signup_enabled" bool)
        (Decode.field "oauth2_providers" (list string))


decodeAuthSettingsString : String -> AuthSettings
decodeAuthSettingsString string =
    case Decode.decodeString decodeAuthSettings string of
        Ok authSettings ->
            authSettings

        Err _ ->
            App.Types.Session.defaultAuthSettings
