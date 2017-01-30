module Components.Timeline.Commands exposing (..)

import Json.Decode as Decode
import Json.Encode as Encode
import Dom.Scroll
import Task
import Process
import Time
import Http
import Components.Timeline.Model exposing (Coto)
import Components.Timeline.Messages exposing (..)


scrollToBottom : msg -> Cmd msg
scrollToBottom msg =
    Process.sleep (1 * Time.millisecond)
    |> Task.andThen (\_ -> (Dom.Scroll.toBottom "timeline"))
    |> Task.attempt (\_ -> msg) 


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
    Decode.map5 Coto
        (Decode.maybe (Decode.field "id" Decode.int))
        (Decode.maybe (Decode.field "postId" Decode.int))
        (Decode.field "content" Decode.string)
        (Decode.field "as_cotonoma" Decode.bool)
        (Decode.succeed False)


encodeCoto : Coto -> Encode.Value
encodeCoto coto =
    Encode.object 
        [ ("coto", 
            (Encode.object 
                [ ("postId", 
                    case coto.postId of
                        Nothing -> Encode.null 
                        Just postId -> Encode.int postId
                  )
                , ("content", Encode.string coto.content)
                ]
            )
          )
        ]
