module App.Server.Post exposing (..)

import Date exposing (Date)
import Http exposing (Request)
import Json.Decode as Decode exposing (maybe, int, string, float, bool)
import Json.Decode.Pipeline exposing (required, optional, hardcoded)
import Json.Encode as Encode
import Util.HttpUtil exposing (httpPost)
import App.Messages exposing (Msg(PostsFetched, CotonomaFetched, CotonomaPosted))
import App.Types.Post exposing (Post, PaginatedPosts)
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


decodePaginatedPosts : Decode.Decoder PaginatedPosts
decodePaginatedPosts =
    Json.Decode.Pipeline.decode PaginatedPosts
        |> required "cotos" (Decode.list decodePost)
        |> required "page_index" int
        |> required "total_pages" int


fetchPosts : Int -> Cmd Msg
fetchPosts pageIndex =
    let
        url =
            "/api/cotos?page=" ++ (toString pageIndex)
    in
        Http.send PostsFetched <|
            Http.get url decodePaginatedPosts


fetchCotonomaPosts : CotonomaKey -> Int -> Cmd Msg
fetchCotonomaPosts key pageIndex =
    let
        url =
            "/api/cotonomas/" ++ key ++ "/cotos?page=" ++ (toString pageIndex)
    in
        Http.send CotonomaFetched <|
            Http.get url <|
                Decode.map2 (,)
                    (Decode.field "cotonoma" decodeCotonoma)
                    (Decode.field "paginated_cotos" decodePaginatedPosts)


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
                [ ( "content", Encode.string post.content )
                , ( "summary"
                  , post.summary
                        |> Maybe.map (\summary -> Encode.string summary)
                        |> Maybe.withDefault Encode.null
                  )
                , ( "cotonoma_id"
                  , maybeCotonoma
                        |> Maybe.map (\cotonoma -> Encode.string cotonoma.id)
                        |> Maybe.withDefault Encode.null
                  )
                ]
            )
          )
        ]
