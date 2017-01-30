module App.Commands exposing (..)

import Http
import Json.Decode as Decode
import App.Types exposing (decodeSession, decodeCotonoma)
import App.Messages exposing (..)
import Components.Timeline.Model exposing (decodeCoto)


fetchSession : Cmd Msg
fetchSession =
    Http.send SessionFetched (Http.get "/api/session" decodeSession)
        
  
fetchCotonoma : String -> Cmd Msg
fetchCotonoma key =
    let
        url = "/api/cotonomas/" ++ key ++ "/cotos"
    in
        Http.send CotonomaFetched
            <| Http.get url
            <| Decode.map2 (,)
                (Decode.field "cotonoma" decodeCotonoma)
                (Decode.field "cotos" (Decode.list decodeCoto))


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
          
