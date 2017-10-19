module App.Server.Coto exposing (..)

import Date
import Http exposing (Request)
import Json.Encode as Encode
import Json.Decode as Decode
import Util.HttpUtil exposing (httpDelete, httpPut)
import App.Messages exposing (Msg(CotoDeleted, ContentUpdated, Cotonomatized))
import App.Types.Coto exposing (CotoId, Coto, Cotonoma)
import App.Server.Amishi exposing (decodeAmishi)
import App.Server.Cotonoma exposing (decodeCotonoma)


decodeCoto : Decode.Decoder Coto
decodeCoto =
    Decode.map7 Coto
        (Decode.field "id" Decode.string)
        (Decode.field "content" Decode.string)
        (Decode.maybe (Decode.field "amishi" decodeAmishi))
        (Decode.maybe (Decode.field "posted_in" decodeCotonoma))
        (Decode.field "inserted_at" (Decode.map Date.fromTime Decode.float))
        (Decode.field "as_cotonoma" Decode.bool)
        (Decode.maybe (Decode.field "cotonoma_key" Decode.string))


deleteCoto : CotoId -> Cmd Msg
deleteCoto cotoId =
    Http.send CotoDeleted ("/api/cotos/" ++ cotoId |> httpDelete)


updateContent : CotoId -> String -> Cmd Msg
updateContent cotoId content =
    let
        url =
            "/api/cotos/" ++ cotoId

        body =
            Http.jsonBody <|
                Encode.object
                    [ ( "coto"
                      , Encode.object [ ( "content", Encode.string content ) ]
                      )
                    ]
    in
        Http.send ContentUpdated (httpPut url body decodeCoto)


cotonomatize : CotoId -> Cmd Msg
cotonomatize cotoId =
    Http.send Cotonomatized <|
        httpPut
            ("/api/cotos/" ++ cotoId ++ "/cotonomatize")
            Http.emptyBody
            decodeCoto
