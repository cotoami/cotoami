module App.Server.Watch
    exposing
        ( decodeWatch
        , fetchWatchlist
        , watch
        , unwatch
        , updateLastPostTimestamp
        )

import Time exposing (Time)
import Http
import Json.Decode as Decode exposing (maybe, float, string, list)
import Json.Decode.Pipeline exposing (required, optional)
import Json.Encode as Encode
import Utils.HttpUtil exposing (ClientId)
import App.Types.Watch exposing (Watch)
import App.Types.Coto exposing (CotonomaKey)
import App.Server.Cotonoma


decodeWatch : Decode.Decoder Watch
decodeWatch =
    Json.Decode.Pipeline.decode Watch
        |> required "id" string
        |> required "cotonoma" App.Server.Cotonoma.decodeCotonoma
        |> optional "last_post_timestamp" (maybe float) Nothing


fetchWatchlist : (Result Http.Error (List Watch) -> msg) -> Cmd msg
fetchWatchlist tag =
    Http.send tag <| Http.get ("/api/watchlist") (list decodeWatch)


watch : (Result Http.Error (List Watch) -> msg) -> ClientId -> CotonomaKey -> Cmd msg
watch tag clientId cotonomaKey =
    let
        url =
            "/api/watchlist/" ++ cotonomaKey
    in
        Utils.HttpUtil.httpPut url clientId Http.emptyBody (list decodeWatch)
            |> Http.send tag


unwatch : (Result Http.Error (List Watch) -> msg) -> ClientId -> CotonomaKey -> Cmd msg
unwatch tag clientId cotonomaKey =
    let
        url =
            "/api/watchlist/" ++ cotonomaKey
    in
        Http.expectJson (list decodeWatch)
            |> Utils.HttpUtil.httpDeleteWithExpect url clientId
            |> Http.send tag


updateLastPostTimestamp :
    (Result Http.Error Watch -> msg)
    -> ClientId
    -> CotonomaKey
    -> Time
    -> Cmd msg
updateLastPostTimestamp tag clientId cotonomaKey timestamp =
    let
        url =
            "/api/watchlist/" ++ cotonomaKey

        body =
            Http.jsonBody <|
                Encode.object [ ( "last_post_timestamp", Encode.float timestamp ) ]
    in
        Http.send tag <|
            Utils.HttpUtil.httpPatch url clientId body decodeWatch
