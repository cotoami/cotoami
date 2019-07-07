module App.Server.Cotonoma exposing
    ( decodeCotonoma
    , decodeCotonomaHolder
    , decodeStats
    , encodeCotonoma
    , fetchCotonomaByKeyOrName
    , fetchCotonomaByName
    , fetchCotonomas
    , fetchStats
    , fetchSuperAndSubCotonomas
    , refreshCotonomaList
    )

import App.Messages exposing (Msg(..))
import App.Server.Amishi exposing (decodeAmishi)
import App.Submodels.Context exposing (Context)
import App.Types.Coto exposing (Cotonoma, CotonomaHolder, CotonomaKey, CotonomaStats)
import Date
import Http
import Json.Decode as Decode exposing (bool, float, int, list, maybe, string)
import Json.Decode.Pipeline exposing (hardcoded, optional, required)
import Json.Encode as Encode


decodeCotonoma : Decode.Decoder Cotonoma
decodeCotonoma =
    Json.Decode.Pipeline.decode Cotonoma
        |> required "id" string
        |> required "key" string
        |> required "name" string
        |> required "shared" bool
        |> required "coto_id" string
        |> optional "owner" (maybe decodeAmishi) Nothing
        |> required "inserted_at" (Decode.map Date.fromTime float)
        |> required "updated_at" (Decode.map Date.fromTime float)
        |> required "timeline_revision" int
        |> required "graph_revision" int
        |> optional "last_post_timestamp" (maybe float) Nothing


decodeCotonomaHolder : Decode.Decoder CotonomaHolder
decodeCotonomaHolder =
    Json.Decode.Pipeline.decode CotonomaHolder
        |> required "cotonoma" decodeCotonoma
        |> optional "posted_in" (maybe decodeCotonoma) Nothing
        |> required "reposted_in" (list decodeCotonoma)


fetchCotonomaByName : (Result Http.Error Cotonoma -> msg) -> String -> Cmd msg
fetchCotonomaByName tag name =
    Http.get ("/api/cotonomas/name/" ++ name) decodeCotonoma
        |> Http.send tag


fetchCotonomaByKeyOrName : (Result Http.Error Cotonoma -> msg) -> String -> Cmd msg
fetchCotonomaByKeyOrName tag keyOrName =
    Http.get ("/api/cotonomas/key-or-name/" ++ keyOrName) decodeCotonoma
        |> Http.send tag


fetchCotonomas : Cmd Msg
fetchCotonomas =
    let
        decodeResponse =
            Decode.map2 (,)
                (Decode.field "global" (Decode.list decodeCotonomaHolder))
                (Decode.field "recent" (Decode.list decodeCotonomaHolder))
    in
    Http.get "/api/cotonomas" decodeResponse
        |> Http.send CotonomasFetched


fetchSuperAndSubCotonomas : Context context -> Cmd Msg
fetchSuperAndSubCotonomas context =
    let
        decodeResponse =
            Decode.map2 (,)
                (Decode.field "super" (Decode.list decodeCotonomaHolder))
                (Decode.field "sub" (Decode.list decodeCotonomaHolder))
    in
    context.cotonoma
        |> Maybe.map
            (\cotonoma ->
                decodeResponse
                    |> Http.get ("/api/cotonomas/" ++ cotonoma.id ++ "/super-and-sub")
                    |> Http.send SuperAndSubCotonomasFetched
            )
        |> Maybe.withDefault Cmd.none


encodeCotonoma : Maybe Cotonoma -> Bool -> String -> Encode.Value
encodeCotonoma maybeCotonoma shared name =
    Encode.object
        [ ( "cotonoma"
          , Encode.object
                [ ( "cotonoma_id"
                  , maybeCotonoma
                        |> Maybe.map (\cotonoma -> Encode.string cotonoma.id)
                        |> Maybe.withDefault Encode.null
                  )
                , ( "name", Encode.string name )
                , ( "shared", Encode.bool shared )
                ]
          )
        ]


fetchStats : (Result Http.Error CotonomaStats -> msg) -> CotonomaKey -> Cmd msg
fetchStats tag cotonomaKey =
    Http.get ("/api/cotonomas/" ++ cotonomaKey ++ "/stats") decodeStats
        |> Http.send tag


decodeStats : Decode.Decoder CotonomaStats
decodeStats =
    Decode.map3 CotonomaStats
        (Decode.field "key" Decode.string)
        (Decode.field "cotos" Decode.int)
        (Decode.field "connections" Decode.int)


refreshCotonomaList : Context a -> Cmd Msg
refreshCotonomaList context =
    Cmd.batch
        [ fetchCotonomas
        , fetchSuperAndSubCotonomas context
        ]
