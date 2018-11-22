module App.Server.Cotonoma exposing (..)

import Date
import Http
import Json.Decode as Decode exposing (maybe, int, string, float, bool)
import Json.Encode as Encode
import Json.Decode.Pipeline exposing (required, optional, hardcoded)
import App.Messages exposing (Msg(..))
import App.Server.Amishi exposing (decodeAmishi)
import App.Types.Coto exposing (Cotonoma, CotonomaKey, CotonomaStats)
import App.Submodels.Context exposing (Context)


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
        |> optional "last_post_timestamp" (maybe int) Nothing


fetchCotonomas : Cmd Msg
fetchCotonomas =
    let
        decodeResponse =
            Decode.map2 (,)
                (Decode.field "global" (Decode.list decodeCotonoma))
                (Decode.field "recent" (Decode.list decodeCotonoma))
    in
        Http.get "/api/cotonomas" decodeResponse
            |> Http.send CotonomasFetched


fetchSubCotonomas : Context a -> Cmd Msg
fetchSubCotonomas context =
    context.cotonoma
        |> Maybe.map
            (\cotonoma ->
                Decode.list decodeCotonoma
                    |> Http.get ("/api/cotonomas/" ++ cotonoma.id ++ "/cotonomas")
                    |> Http.send SubCotonomasFetched
            )
        |> Maybe.withDefault Cmd.none


encodeCotonoma : Maybe Cotonoma -> Bool -> String -> Encode.Value
encodeCotonoma maybeCotonoma shared name =
    Encode.object
        [ ( "cotonoma"
          , (Encode.object
                [ ( "cotonoma_id"
                  , maybeCotonoma
                        |> Maybe.map (\cotonoma -> Encode.string cotonoma.id)
                        |> Maybe.withDefault Encode.null
                  )
                , ( "name", Encode.string name )
                , ( "shared", Encode.bool shared )
                ]
            )
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
