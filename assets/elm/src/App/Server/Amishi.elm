module App.Server.Amishi exposing (decodeAmishi, fetchAmishi)

import Http
import Json.Decode as Decode exposing (maybe, string, bool)
import App.Types.Amishi exposing (Amishi)


decodeAmishi : Decode.Decoder Amishi
decodeAmishi =
    Decode.map6 Amishi
        (Decode.field "id" string)
        (Decode.field "email" (maybe string))
        (Decode.field "auth_provider" (maybe string))
        (Decode.field "owner" bool)
        (Decode.field "avatar_url" string)
        (Decode.field "display_name" string)


fetchAmishi : (Result Http.Error Amishi -> msg) -> String -> Cmd msg
fetchAmishi msg email =
    Http.send msg <|
        Http.get ("/api/amishis/email/" ++ email) <|
            decodeAmishi
