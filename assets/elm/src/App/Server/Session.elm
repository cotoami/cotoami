module App.Server.Session
    exposing
        ( decodeSession
        , fetchSession
        , decodeAuthSettingsString
        )

import Http
import Json.Decode as Decode exposing (bool, string, list)
import App.Messages exposing (Msg(..))
import App.Server.Amishi
import App.Types.Session exposing (Session, AuthSettings)


decodeSession : Decode.Decoder Session
decodeSession =
    Decode.map4 Session
        (Decode.field "amishi" App.Server.Amishi.decodeAmishi)
        (Decode.field "token" string)
        (Decode.field "websocket_url" string)
        (Decode.field "lang" string)


fetchSession : Cmd Msg
fetchSession =
    Http.send SessionFetched (Http.get "/api/public/session" decodeSession)


decodeAuthSettings : Decode.Decoder AuthSettings
decodeAuthSettings =
    Decode.map2 AuthSettings
        (Decode.field "signup_enabled" bool)
        (Decode.field "oauth_providers" (list string))


decodeAuthSettingsString : String -> AuthSettings
decodeAuthSettingsString string =
    case Decode.decodeString decodeAuthSettings string of
        Ok authSettings ->
            authSettings

        Err _ ->
            App.Types.Session.defaultAuthSettings
