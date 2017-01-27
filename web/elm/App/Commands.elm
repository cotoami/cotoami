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


deleteCoto : Int -> Cmd Msg
deleteCoto cotoId =
    Http.send 
        CotoDeleted
        (Http.request
          { method = "DELETE"
          , headers = []
          , url = "/api/cotos/" ++ toString(cotoId)
          , body = Http.emptyBody
          , expect = Http.expectString 
          , timeout = Nothing
          , withCredentials = False
          }
        )
          
