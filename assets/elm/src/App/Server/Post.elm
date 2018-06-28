module App.Server.Post exposing (..)

import Date exposing (Date)
import Http exposing (Request)
import Json.Decode as Decode exposing (maybe, int, string, float, bool)
import Json.Decode.Pipeline exposing (required, optional, hardcoded)
import Json.Encode as Encode
import Util.HttpUtil exposing (ClientId, httpPost)
import App.Messages
    exposing
        ( Msg
            ( PostsFetched
            , CotonomaFetched
            , SearchResultsFetched
            , CotonomaPosted
            )
        )
import App.Types.Context exposing (Context)
import App.Types.Post exposing (Post, PaginatedPosts)
import App.Types.Coto exposing (CotoId, Cotonoma, CotonomaKey)
import App.Types.Timeline exposing (Filter)
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


fetchPosts : Int -> Filter -> Cmd Msg
fetchPosts pageIndex filter =
    let
        url =
            "/api/cotos"
                ++ ("?page=" ++ (toString pageIndex))
                ++ (if filter.excludePinnedGraph then
                        "&exclude_pinned_graph=true"
                    else
                        ""
                   )
                ++ (if filter.excludePostsInCotonoma then
                        "&exclude_posts_in_cotonoma=true"
                    else
                        ""
                   )
    in
        Http.send PostsFetched <|
            Http.get url decodePaginatedPosts


fetchCotonomaPosts : Int -> Filter -> CotonomaKey -> Cmd Msg
fetchCotonomaPosts pageIndex filter key =
    let
        url =
            ("/api/cotonomas/" ++ key ++ "/cotos")
                ++ ("?page=" ++ (toString pageIndex))
                ++ (if filter.excludePinnedGraph then
                        "&exclude_pinned_graph=true"
                    else
                        ""
                   )
    in
        Http.send CotonomaFetched <|
            Http.get url <|
                Decode.map2 (,)
                    (Decode.field "cotonoma" decodeCotonoma)
                    (Decode.field "paginated_cotos" decodePaginatedPosts)


fetchPostsByContext : Int -> Filter -> Context -> Cmd Msg
fetchPostsByContext pageIndex filter context =
    context.cotonoma
        |> Maybe.map (\cotonoma -> fetchCotonomaPosts pageIndex filter cotonoma.key)
        |> Maybe.withDefault (fetchPosts pageIndex filter)


search : String -> Cmd Msg
search query =
    let
        url =
            "/api/search/" ++ (query)
    in
        Http.send SearchResultsFetched <|
            Http.get url decodePaginatedPosts


postRequest : ClientId -> Maybe Cotonoma -> Post -> Request Post
postRequest clientId maybeCotonoma post =
    httpPost
        "/api/cotos"
        clientId
        (Http.jsonBody (encodePost maybeCotonoma post))
        decodePost


post : ClientId -> Maybe Cotonoma -> (Result Http.Error Post -> msg) -> Post -> Cmd msg
post clientId maybeCotonoma msgAfterPosted post =
    postRequest clientId maybeCotonoma post
        |> Http.send msgAfterPosted


postCotonoma : ClientId -> Maybe Cotonoma -> Int -> String -> Cmd Msg
postCotonoma clientId maybeCotonoma postId name =
    Http.send (CotonomaPosted postId) <|
        httpPost
            "/api/cotonomas"
            clientId
            (Http.jsonBody (encodeCotonoma maybeCotonoma postId name))
            decodePost


encodePost : Maybe Cotonoma -> Post -> Encode.Value
encodePost maybeCotonoma post =
    Encode.object
        [ ( "coto"
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
