module App.Commands exposing (..)

import Http
import Json.Decode as Decode
import Json.Encode as Encode
import App.Model exposing (..)
import App.Messages exposing (..)

-- Session

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


-- Coto

fetchCotos : Cmd Msg
fetchCotos =
    Http.send CotosFetched (Http.get "/api/cotos" (Decode.list decodeCoto))


postCoto : Coto -> Cmd Msg
postCoto coto =
    Http.send 
        CotoPosted 
        (Http.post "/api/cotos" (Http.jsonBody (encodeCoto coto)) decodeCoto)
        
        
decodeCoto : Decode.Decoder Coto
decodeCoto =
    Decode.map Coto
        (Decode.field "content" Decode.string)


encodeCoto : Coto -> Encode.Value
encodeCoto coto =
    Encode.object 
        [("coto", 
            (Encode.object [("content", Encode.string coto.content)])
         )
        ]


-- 

requestSignin : String -> Bool -> Cmd Msg
requestSignin email saveAnonymous =
    let
        url = "/api/signin/request/" ++ email ++
            (if saveAnonymous then "/yes" else "/no")
    in
      Http.send SigninRequestDone (Http.get url Decode.string)
