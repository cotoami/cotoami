module App.Server.Amishi exposing (..)

import Http
import Json.Decode as Decode
import App.Types.Amishi exposing (Amishi)


decodeAmishi : Decode.Decoder Amishi
decodeAmishi =
    Decode.map5 Amishi
        (Decode.field "id" Decode.string)
        (Decode.field "email" Decode.string)
        (Decode.field "owner" Decode.bool)
        (Decode.field "avatar_url" Decode.string)
        (Decode.field "display_name" Decode.string)


fetchAmishi : (Result Http.Error Amishi -> msg) -> String -> Cmd msg
fetchAmishi msg email =
    Http.send msg <|
        Http.get ("/api/amishis/email/" ++ email) <|
            decodeAmishi
