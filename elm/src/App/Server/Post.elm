module App.Server.Post exposing (..)

import Date exposing (Date)
import Http exposing (Request)
import Json.Decode as Decode exposing (maybe, int, string, float, bool)
import Json.Decode.Pipeline exposing (required, optional, hardcoded)
import Json.Encode as Encode
import Util.HttpUtil exposing (httpPost)
import App.Messages exposing (Msg(PostsFetched, CotonomaFetched, CotonomaPosted))
import App.Types.Post exposing (Post)
import App.Types.Coto exposing (CotoId, Cotonoma, CotonomaKey)
import App.Server.Amishi exposing (decodeAmishi)
import App.Server.Cotonoma exposing (decodeCotonoma, encodeCotonoma)


decodePost : Decode.Decoder Post
decodePost =
    Json.Decode.Pipeline.decode Post
        |> hardcoded Nothing
        |> optional "id" (maybe string) Nothing
        |> required "content" string
        |> optional "summary" (maybe string) Nothing
        |> optional "amishi" (maybe decodeAmishi) Nothing
        |> optional "posted_in" (maybe decodeCotonoma) Nothing
        |> optional "inserted_at" (maybe (Decode.map Date.fromTime float)) Nothing
        |> required "as_cotonoma" bool
        |> optional "cotonoma_key" (maybe string) Nothing
        |> hardcoded False


fetchPosts : Cmd Msg
fetchPosts =
    Http.send PostsFetched (Http.get "/api/cotos" (Decode.list decodePost))


fetchCotonomaPosts : CotonomaKey -> Cmd Msg
fetchCotonomaPosts key =
    Http.send CotonomaFetched <|
        Http.get ("/api/cotonomas/" ++ key ++ "/cotos") <|
            Decode.map2 (,)
                (Decode.field "cotonoma" decodeCotonoma)
                (Decode.field "cotos" (Decode.list decodePost))


postRequest : String -> Maybe Cotonoma -> Post -> Request Post
postRequest clientId maybeCotonoma post =
    httpPost
        "/api/cotos"
        (Http.jsonBody (encodePost clientId maybeCotonoma post))
        decodePost


post : String -> Maybe Cotonoma -> (Result Http.Error Post -> msg) -> Post -> Cmd msg
post clientId maybeCotonoma msgAfterPosted post =
    postRequest clientId maybeCotonoma post
        |> Http.send msgAfterPosted


postCotonoma : String -> Maybe Cotonoma -> Int -> String -> Cmd Msg
postCotonoma clientId maybeCotonoma postId name =
    Http.send (CotonomaPosted postId) <|
        httpPost
            "/api/cotonomas"
            (Http.jsonBody (encodeCotonoma clientId maybeCotonoma postId name))
            decodePost


encodePost : String -> Maybe Cotonoma -> Post -> Encode.Value
encodePost clientId maybeCotonoma post =
    Encode.object
        [ ( "clientId", Encode.string clientId )
        , ( "coto"
          , (Encode.object
                [ ( "cotonoma_id"
                  , case maybeCotonoma of
                        Nothing ->
                            Encode.null

                        Just cotonoma ->
                            Encode.string cotonoma.id
                  )
                , ( "content", Encode.string post.content )
                ]
            )
          )
        ]
