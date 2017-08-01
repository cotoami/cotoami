module App.Server.Post exposing (..)

import Http
import Json.Decode as Decode
import App.Messages exposing (Msg(..))
import App.Types.Post exposing (Post)
import App.Types.Coto exposing (CotonomaKey)
import App.Server.Amishi exposing (decodeAmishi)
import App.Server.Cotonoma exposing (decodeCotonoma)


decodePost : Decode.Decoder Post
decodePost =
    Decode.map8 Post
        (Decode.maybe (Decode.field "postId" Decode.int))
        (Decode.maybe (Decode.field "id" Decode.string))
        (Decode.field "content" Decode.string)
        (Decode.maybe (Decode.field "amishi" decodeAmishi))
        (Decode.maybe (Decode.field "posted_in" decodeCotonoma))
        (Decode.field "as_cotonoma" Decode.bool)
        (Decode.field "cotonoma_key" Decode.string)
        (Decode.succeed False)


fetchCotonomaPosts : CotonomaKey -> Cmd Msg
fetchCotonomaPosts key =
    Http.send CotonomaFetched
        <| Http.get ("/api/cotonomas/" ++ key ++ "/cotos")
        <| Decode.map3 (,,)
            (Decode.field "cotonoma" decodeCotonoma)
            (Decode.field "members" (Decode.list decodeAmishi))
            (Decode.field "cotos" (Decode.list decodePost))
