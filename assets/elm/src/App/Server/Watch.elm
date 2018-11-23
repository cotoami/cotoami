module App.Server.Watch exposing (decodeWatch, fetchWatchlist, watch, unwatch)

import Http
import Json.Decode as Decode exposing (maybe, float, string, list)
import Json.Decode.Pipeline exposing (required, optional)
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
