module App.Server.Post exposing
    ( decodePost
    , fetchCotonomaPosts
    , fetchHomePosts
    , fetchPostsByContext
    , fetchRandomPosts
    , post
    , postCotonoma
    , postRequest
    , search
    )

import App.Messages
    exposing
        ( Msg
            ( CotonomaPostsFetched
            , HomePostsFetched
            , SearchResultsFetched
            )
        )
import App.Server.Amishi
import App.Server.Cotonoma
import App.Server.Pagination exposing (PaginatedList)
import App.Submodels.Context exposing (Context)
import App.Types.Coto exposing (CotoId, Cotonoma, CotonomaKey)
import App.Types.Post exposing (Post)
import App.Types.TimelineFilter exposing (TimelineFilter)
import Date exposing (Date)
import Http exposing (Request)
import Json.Decode as Decode exposing (bool, float, int, maybe, string)
import Json.Decode.Pipeline exposing (hardcoded, optional, required)
import Json.Encode as Encode
import Utils.HttpUtil exposing (ClientId, httpPost)


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


filterAsQueryString : TimelineFilter -> String
filterAsQueryString filter =
    [ if filter.excludePinnedGraph then
        "&exclude_pinned_graph=true"

      else
        ""
    , if filter.excludePostsInCotonoma then
        "&exclude_posts_in_cotonoma=true"

      else
        ""
    ]
        |> List.foldl (++) ""


fetchHomePosts : Int -> TimelineFilter -> Cmd Msg
fetchHomePosts pageIndex filter =
    let
        url =
            "/api/cotos"
                ++ ("?page=" ++ toString pageIndex)
                ++ filterAsQueryString filter
    in
    Http.send HomePostsFetched <|
        Http.get url (App.Server.Pagination.decodePaginatedList decodePost)


fetchCotonomaPosts : Int -> TimelineFilter -> CotonomaKey -> Cmd Msg
fetchCotonomaPosts pageIndex filter key =
    let
        url =
            ("/api/cotonomas/" ++ key ++ "/cotos")
                ++ ("?page=" ++ toString pageIndex)
                ++ filterAsQueryString filter
    in
    Http.send CotonomaPostsFetched <|
        Http.get url <|
            Decode.map2 (,)
                (Decode.field "cotonoma" App.Server.Cotonoma.decodeCotonoma)
                (Decode.field "paginated_cotos" (App.Server.Pagination.decodePaginatedList decodePost))


fetchPostsByContext : Int -> TimelineFilter -> Context a -> Cmd Msg
fetchPostsByContext pageIndex filter context =
    context.cotonoma
        |> Maybe.map (\cotonoma -> fetchCotonomaPosts pageIndex filter cotonoma.key)
        |> Maybe.withDefault (fetchHomePosts pageIndex filter)


fetchRandomPosts :
    (Result Http.Error (List Post) -> msg)
    -> TimelineFilter
    -> Maybe CotonomaKey
    -> Cmd msg
fetchRandomPosts tag filter maybeCotonomaKey =
    let
        url =
            (maybeCotonomaKey
                |> Maybe.map (\key -> "/api/cotonomas/" ++ key ++ "/cotos/random?page=0")
                |> Maybe.withDefault "/api/cotos/random?page=0"
            )
                ++ filterAsQueryString filter
    in
    Http.get url (Decode.list decodePost) |> Http.send tag


search : String -> Cmd Msg
search query =
    let
        url =
            "/api/search/" ++ query
    in
    Http.get url (Decode.list decodePost) |> Http.send SearchResultsFetched


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
          , Encode.object
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
        ]
