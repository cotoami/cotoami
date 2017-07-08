module App.Commands exposing (..)

import Http
import Json.Decode as Decode
import Utils
import App.Types
    exposing
        ( Amishi
        , Cotonoma
        , CotonomaKey
        , decodeSession
        , decodeAmishi
        , decodeCotonoma
        )
import App.Messages exposing (..)
import Components.Timeline.Model exposing (decodePost)


fetchSession : Cmd Msg
fetchSession =
    Http.send SessionFetched (Http.get "/api/session" decodeSession)


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
                <| Http.get ("/api/cotonomas?cotonoma_id=" ++ (toString cotonoma.id))
                <| Decode.list decodeCotonoma


fetchAmishi : (Result Http.Error Amishi -> msg) -> String -> Cmd msg
fetchAmishi msg email =
    Http.send msg
        <| Http.get ("/api/amishis/email/" ++ email)
        <| decodeAmishi


fetchCotonoma : CotonomaKey -> Cmd Msg
fetchCotonoma key =
    Http.send CotonomaFetched
        <| Http.get ("/api/cotonomas/" ++ key ++ "/cotos")
        <| Decode.map3 (,,)
            (Decode.field "cotonoma" decodeCotonoma)
            (Decode.field "members" (Decode.list decodeAmishi))
            (Decode.field "cotos" (Decode.list decodePost))


deleteCoto : Int -> Cmd Msg
deleteCoto cotoId =
    Http.send
        CotoDeleted
        ("/api/cotos/" ++ toString(cotoId) |> Utils.delete)
