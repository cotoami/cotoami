module App.Server.Coto exposing
    ( cotonomatize
    , decodeCoto
    , deleteCoto
    , updateContent
    )

import App.Messages exposing (Msg(CotoDeleted, CotoUpdated, Cotonomatized))
import App.Server.Amishi
import App.Server.Cotonoma
import App.Types.Coto exposing (Coto, CotoContent, CotoId, Cotonoma)
import Date
import Http exposing (Request)
import Json.Decode as Decode exposing (bool, float, int, list, maybe, string)
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as Encode
import Utils.HttpUtil exposing (ClientId, httpDelete, httpPut)


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
        |> required "reposted_in" (list App.Server.Cotonoma.decodeCotonoma)
        |> optional "incoming" (maybe int) Nothing
        |> optional "outgoing" (maybe int) Nothing


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
