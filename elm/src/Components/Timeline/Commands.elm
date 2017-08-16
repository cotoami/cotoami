module Components.Timeline.Commands exposing (..)

import Json.Decode as Decode
import Json.Encode as Encode
import Dom.Scroll
import Task
import Process
import Time
import Http exposing (Request)
import Utils exposing (httpPost)
import App.Types.Coto exposing (Cotonoma)
import App.Types.Post exposing (Post)
import App.Messages exposing (..)
import App.Server.Coto exposing (decodePost)


scrollToBottom : msg -> Cmd msg
scrollToBottom msg =
    Process.sleep (1 * Time.millisecond)
    |> Task.andThen (\_ -> (Dom.Scroll.toBottom "timeline"))
    |> Task.attempt (\_ -> msg)


fetchPosts : Cmd Msg
fetchPosts =
    Http.send PostsFetched (Http.get "/api/cotos" (Decode.list decodePost))


postRequest : String -> Maybe Cotonoma -> Post -> Request Post
postRequest clientId maybeCotonoma post =
    httpPost
        "/api/cotos"
        (Http.jsonBody (encodePost clientId maybeCotonoma post))
        decodePost


post : String -> Maybe Cotonoma -> ((Result Http.Error Post) -> msg) -> Post -> Cmd msg
post clientId maybeCotonoma msgAfterPosted post =
    postRequest clientId maybeCotonoma post
    |> Http.send msgAfterPosted


encodePost : String -> Maybe Cotonoma -> Post -> Encode.Value
encodePost clientId maybeCotonoma post =
    Encode.object
        [ ( "clientId", Encode.string clientId )
        , ( "coto"
          , (Encode.object
                [ ( "cotonoma_id"
                  , case maybeCotonoma of
                        Nothing -> Encode.null
                        Just cotonoma -> Encode.string cotonoma.id
                  )
                , ( "postId"
                  , case post.postId of
                        Nothing -> Encode.null
                        Just postId -> Encode.int postId
                  )
                , ( "content", Encode.string post.content )
                ]
            )
          )
        ]
