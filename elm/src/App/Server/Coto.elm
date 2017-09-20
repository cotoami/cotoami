module App.Server.Coto exposing (..)

import Http exposing (Request)
import Json.Decode as Decode
import Json.Encode as Encode
import Util.HttpUtil exposing (httpDelete, httpPost)
import App.Messages exposing (Msg(PostsFetched, CotonomaFetched, CotoDeleted, CotonomaPosted))
import App.Types.Post exposing (Post)
import App.Types.Coto exposing (CotoId, Cotonoma, CotonomaKey, Member)
import App.Server.Amishi exposing (decodeAmishi)
import App.Server.Cotonoma exposing (decodeCotonoma, encodeCotonoma)


decodePost : Decode.Decoder Post
decodePost =
    Decode.map8 Post
        (Decode.maybe (Decode.field "postId" Decode.int))
        (Decode.maybe (Decode.field "id" Decode.string))
        (Decode.field "content" Decode.string)
        (Decode.maybe (Decode.field "amishi" decodeAmishi))
        (Decode.maybe (Decode.field "posted_in" decodeCotonoma))
        (Decode.field "as_cotonoma" Decode.bool)
        (Decode.maybe (Decode.field "cotonoma_key" Decode.string))
        (Decode.succeed False)


fetchPosts : Cmd Msg
fetchPosts =
    Http.send PostsFetched (Http.get "/api/cotos" (Decode.list decodePost))


fetchCotonomaPosts : CotonomaKey -> Cmd Msg
fetchCotonomaPosts key =
    Http.send CotonomaFetched
        <| Http.get ("/api/cotonomas/" ++ key ++ "/cotos")
        <| Decode.map3 (,,)
            (Decode.field "cotonoma" decodeCotonoma)
            (Decode.field "members" (Decode.list decodeAmishi))
            (Decode.field "cotos" (Decode.list decodePost))


deleteCoto : CotoId -> Cmd Msg
deleteCoto cotoId =
    Http.send
        CotoDeleted
        ("/api/cotos/" ++ cotoId |> httpDelete)


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


postCotonoma : String -> Maybe Cotonoma -> Int -> List Member -> String -> Cmd Msg
postCotonoma clientId maybeCotonoma postId members name =
    Http.send CotonomaPosted
        <| httpPost
            "/api/cotonomas"
            (Http.jsonBody (encodeCotonoma clientId maybeCotonoma postId members name))
            decodePost


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
