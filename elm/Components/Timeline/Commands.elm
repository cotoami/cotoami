module Components.Timeline.Commands exposing (..)

import Json.Decode as Decode
import Json.Encode as Encode
import Dom.Scroll
import Task
import Process
import Time
import Http
import App.Types exposing (Cotonoma)
import Components.Timeline.Model exposing (Post, decodePost)
import Components.Timeline.Messages exposing (..)


scrollToBottom : msg -> Cmd msg
scrollToBottom msg =
    Process.sleep (1 * Time.millisecond)
    |> Task.andThen (\_ -> (Dom.Scroll.toBottom "timeline"))
    |> Task.attempt (\_ -> msg) 


fetchPosts : Cmd Msg
fetchPosts =
    Http.send PostsFetched (Http.get "/api/cotos" (Decode.list decodePost))


post : Maybe Cotonoma -> Post -> Cmd Msg
post maybeCotonoma post =
    Http.send Posted 
        <| Http.post 
            "/api/cotos" 
            (Http.jsonBody (encodePost maybeCotonoma post)) 
            decodePost
        

encodePost : Maybe Cotonoma -> Post -> Encode.Value
encodePost maybeCotonoma post =
    Encode.object 
        [ ("coto", 
            (Encode.object 
                [ ("cotonoma_id"
                  , case maybeCotonoma of
                        Nothing -> Encode.null 
                        Just cotonoma -> Encode.int cotonoma.id
                  )
                , ("postId"
                  , case post.postId of
                        Nothing -> Encode.null 
                        Just postId -> Encode.int postId
                  )
                , ("content", Encode.string post.content)
                ]
            )
          )
        ]
