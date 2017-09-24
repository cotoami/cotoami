module App.Server.Coto exposing (..)

import Http exposing (Request)
import Json.Encode as Encode
import Json.Decode as Decode
import Util.HttpUtil exposing (httpDelete, httpPut)
import App.Messages exposing (Msg(CotoDeleted, ContentUpdated))
import App.Types.Coto exposing (CotoId)


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

        response =
            Decode.succeed "done"
    in
        Http.send ContentUpdated (httpPut url body response)
