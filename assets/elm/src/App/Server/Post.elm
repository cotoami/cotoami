module App.Server.Post exposing (..)

import Date exposing (Date)
import Http exposing (Request)
import Json.Decode as Decode exposing (maybe, int, string, float, bool)
import Json.Decode.Pipeline exposing (required, optional, hardcoded)
import Json.Encode as Encode
import Utils.HttpUtil exposing (ClientId, httpPost)
import App.Messages
    exposing
        ( Msg
            ( HomePostsFetched
            , CotonomaPostsFetched
            , SearchResultsFetched
            )
        )
import App.Types.Coto exposing (CotoId, Cotonoma, CotonomaKey)
import App.Types.Post exposing (Post, PaginatedPosts)
import App.Types.TimelineFilter exposing (TimelineFilter)
import App.Submodels.Context exposing (Context)
import App.Server.Amishi
import App.Server.Cotonoma


decodePost : Decode.Decoder Post
decodePost =
    Json.Decode.Pipeline.decode Post
        |> hardcoded Nothing
        |> optional "id" (maybe string) Nothing
        |> required "content" string
        |> optional "summary" (maybe string) Nothing
        |> optional "amishi" (maybe App.Server.Amishi.decodeAmishi) Nothing
        |> optional "posted_in" (maybe App.Server.Cotonoma.decodeCotonoma) Nothing
        |> optional "inserted_at" (maybe (Decode.map Date.fromTime float)) Nothing
        |> required "as_cotonoma" bool
        |> optional "cotonoma" (maybe App.Server.Cotonoma.decodeCotonoma) Nothing
        |> hardcoded False


decodePaginatedPosts : Decode.Decoder PaginatedPosts
decodePaginatedPosts =
    Json.Decode.Pipeline.decode PaginatedPosts
        |> required "cotos" (Decode.list decodePost)
        |> required "page_index" int
        |> required "total_pages" int


fetchHomePosts : Int -> TimelineFilter -> Cmd Msg
fetchHomePosts pageIndex filter =
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
        Http.send HomePostsFetched <|
            Http.get url decodePaginatedPosts


fetchCotonomaPosts : Int -> TimelineFilter -> CotonomaKey -> Cmd Msg
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
        Http.send CotonomaPostsFetched <|
            Http.get url <|
                Decode.map2 (,)
                    (Decode.field "cotonoma" App.Server.Cotonoma.decodeCotonoma)
                    (Decode.field "paginated_cotos" decodePaginatedPosts)


fetchPostsByContext : Int -> TimelineFilter -> Context a -> Cmd Msg
fetchPostsByContext pageIndex filter context =
    context.cotonoma
        |> Maybe.map (\cotonoma -> fetchCotonomaPosts pageIndex filter cotonoma.key)
        |> Maybe.withDefault (fetchHomePosts pageIndex filter)


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
post clientId maybeCotonoma tag post =
    postRequest clientId maybeCotonoma post
        |> Http.send tag


postCotonoma :
    ClientId
    -> Maybe Cotonoma
    -> (Result Http.Error Post -> msg)
    -> Bool
    -> String
    -> Cmd msg
postCotonoma clientId maybeCotonoma tag shared name =
    let
        body =
            App.Server.Cotonoma.encodeCotonoma maybeCotonoma shared name
                |> Http.jsonBody
    in
        httpPost "/api/cotonomas" clientId body decodePost
            |> Http.send tag


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
