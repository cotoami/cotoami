module App.Server.Coto exposing (..)

import Http exposing (Request)
import Util.HttpUtil exposing (httpDelete)
import App.Messages exposing (Msg(CotoDeleted))
import App.Types.Coto exposing (CotoId)


deleteCoto : CotoId -> Cmd Msg
deleteCoto cotoId =
    Http.send
        CotoDeleted
        ("/api/cotos/" ++ cotoId |> httpDelete)
