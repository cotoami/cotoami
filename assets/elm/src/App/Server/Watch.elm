module App.Server.Watch exposing (decodeWatch, fetchWatchlist, watch)

import Http
import Json.Decode as Decode exposing (maybe, int, string, list)
import Json.Decode.Pipeline exposing (required, optional)
import Utils.HttpUtil exposing (ClientId, httpPut)
import App.Types.Watch exposing (Watch)
import App.Types.Coto exposing (CotonomaKey)
import App.Server.Cotonoma


decodeWatch : Decode.Decoder Watch
decodeWatch =
    Json.Decode.Pipeline.decode Watch
        |> required "id" string
        |> required "cotonoma" App.Server.Cotonoma.decodeCotonoma
        |> optional "last_post_timestamp" (maybe int) Nothing


fetchWatchlist : (Result Http.Error (List Watch) -> msg) -> Cmd msg
fetchWatchlist tag =
    Http.send tag <| Http.get ("/api/watchlist") (list decodeWatch)


watch : (Result Http.Error (List Watch) -> msg) -> ClientId -> CotonomaKey -> Cmd msg
watch tag clientId cotonomaKey =
    let
        url =
            "/api/watchlist/" ++ cotonomaKey
    in
        httpPut url clientId Http.emptyBody (list decodeWatch)
            |> Http.send tag
