module App.Server.Cotonoma exposing (..)

import Http
import Json.Decode as Decode
import App.Messages exposing (Msg(..))
import App.Server.Amishi exposing (decodeAmishi)
import App.Types.Coto exposing (Cotonoma, CotonomaKey)


decodeCotonoma : Decode.Decoder Cotonoma
decodeCotonoma =
    Decode.map5 Cotonoma
        (Decode.field "id" Decode.string)
        (Decode.field "key" Decode.string)
        (Decode.field "name" Decode.string)
        (Decode.field "coto_id" Decode.string)
        (Decode.maybe (Decode.field "owner" decodeAmishi))


fetchRecentCotonomas : Cmd Msg
fetchRecentCotonomas =
    Http.send RecentCotonomasFetched
        <| Http.get "/api/cotonomas"
        <| Decode.list decodeCotonoma


fetchSubCotonomas : Maybe Cotonoma -> Cmd Msg
fetchSubCotonomas maybeCotonoma =
    case maybeCotonoma of
        Nothing -> Cmd.none
        Just cotonoma ->
            Http.send SubCotonomasFetched
                <| Http.get ("/api/cotonomas?cotonoma_id=" ++ cotonoma.id)
                <| Decode.list decodeCotonoma
