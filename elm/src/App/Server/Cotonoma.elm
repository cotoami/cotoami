module App.Server.Cotonoma exposing (..)

import Date
import Http
import Json.Decode as Decode exposing (maybe, int, string, float, bool)
import Json.Encode as Encode
import Json.Decode.Pipeline exposing (required, optional, hardcoded)
import Util.HttpUtil exposing (httpPut, httpDelete)
import App.Messages exposing (Msg(..))
import App.Server.Amishi exposing (decodeAmishi)
import App.Types.Coto exposing (Cotonoma, CotonomaKey, CotonomaStats)


decodeCotonoma : Decode.Decoder Cotonoma
decodeCotonoma =
    Json.Decode.Pipeline.decode Cotonoma
        |> required "id" string
        |> required "key" string
        |> required "name" string
        |> required "pinned" bool
        |> required "coto_id" string
        |> optional "owner" (maybe decodeAmishi) Nothing
        |> required "inserted_at" (Decode.map Date.fromTime float)
        |> required "updated_at" (Decode.map Date.fromTime float)
        |> required "timeline_revision" int
        |> required "graph_revision" int


fetchCotonomas : Cmd Msg
fetchCotonomas =
    Http.send CotonomasFetched <|
        Http.get "/api/cotonomas" <|
            Decode.map2 (,)
                (Decode.field "pinned" (Decode.list decodeCotonoma))
                (Decode.field "recent" (Decode.list decodeCotonoma))


fetchSubCotonomas : Maybe Cotonoma -> Cmd Msg
fetchSubCotonomas maybeCotonoma =
    maybeCotonoma
        |> Maybe.map
            (\cotonoma ->
                Decode.list decodeCotonoma
                    |> Http.get ("/api/cotonomas/" ++ cotonoma.id ++ "/cotonomas")
                    |> Http.send SubCotonomasFetched
            )
        |> Maybe.withDefault Cmd.none


encodeCotonoma : String -> Maybe Cotonoma -> Int -> String -> Encode.Value
encodeCotonoma clientId maybeCotonoma postId name =
    Encode.object
        [ ( "clientId", Encode.string clientId )
        , ( "cotonoma"
          , (Encode.object
                [ ( "cotonoma_id"
                  , case maybeCotonoma of
                        Nothing ->
                            Encode.null

                        Just cotonoma ->
                            Encode.string cotonoma.id
                  )
                , ( "postId", Encode.int postId )
                , ( "name", Encode.string name )
                ]
            )
          )
        ]


pinOrUnpinCotonoma : Bool -> CotonomaKey -> Cmd Msg
pinOrUnpinCotonoma pinOrUnpin cotonomaKey =
    let
        url =
            "/api/cotonomas/pin/" ++ cotonomaKey
    in
        Http.send CotonomaPinnedOrUnpinned
            (if pinOrUnpin then
                httpPut url Http.emptyBody Decode.string
             else
                httpDelete url
            )


fetchStats : CotonomaKey -> Cmd Msg
fetchStats cotonomaKey =
    Http.send CotonomaStatsFetched <|
        Http.get ("/api/cotonomas/" ++ cotonomaKey ++ "/stats") decodeStats


decodeStats : Decode.Decoder CotonomaStats
decodeStats =
    Decode.map3 CotonomaStats
        (Decode.field "key" Decode.string)
        (Decode.field "cotos" Decode.int)
        (Decode.field "connections" Decode.int)
