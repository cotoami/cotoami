module App.Server.Coto exposing (..)

import Date
import Http exposing (Request)
import Json.Encode as Encode
import Json.Decode as Decode exposing (maybe, string, bool, float)
import Json.Decode.Pipeline exposing (required, optional)
import Util.HttpUtil exposing (ClientId, httpDelete, httpPut)
import App.Messages exposing (Msg(CotoDeleted, CotoUpdated, Cotonomatized))
import App.Types.Coto exposing (CotoId, Coto, CotoContent, Cotonoma)
import App.Server.Amishi
import App.Server.Cotonoma


decodeCoto : Decode.Decoder Coto
decodeCoto =
    Json.Decode.Pipeline.decode Coto
        |> required "id" string
        |> required "content" string
        |> optional "summary" (maybe string) Nothing
        |> optional "amishi" (maybe App.Server.Amishi.decodeAmishi) Nothing
        |> optional "posted_in" (maybe App.Server.Cotonoma.decodeCotonoma) Nothing
        |> required "inserted_at" (Decode.map Date.fromTime float)
        |> optional "cotonoma" (maybe App.Server.Cotonoma.decodeCotonoma) Nothing


deleteCoto : ClientId -> CotoId -> Cmd Msg
deleteCoto clientId cotoId =
    Http.send CotoDeleted (httpDelete ("/api/cotos/" ++ cotoId) clientId)


updateContent : ClientId -> CotoId -> Bool -> CotoContent -> Cmd Msg
updateContent clientId cotoId shared content =
    let
        url =
            "/api/cotos/" ++ cotoId

        body =
            Http.jsonBody <|
                Encode.object
                    [ ( "coto"
                      , Encode.object
                            [ ( "content", Encode.string content.content )
                            , ( "summary"
                              , content.summary
                                    |> Maybe.withDefault ""
                                    |> Encode.string
                              )
                            , ( "shared", Encode.bool shared )
                            ]
                      )
                    ]
    in
        Http.send CotoUpdated (httpPut url clientId body decodeCoto)


cotonomatize : ClientId -> CotoId -> Cmd Msg
cotonomatize clientId cotoId =
    Http.send Cotonomatized <|
        httpPut
            ("/api/cotos/" ++ cotoId ++ "/cotonomatize")
            clientId
            Http.emptyBody
            decodeCoto
