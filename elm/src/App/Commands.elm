module App.Commands exposing (..)

import Http
import Utils
import App.Types.Coto exposing (CotoId, Cotonoma, CotonomaKey)
import App.Messages exposing (..)


deleteCoto : CotoId -> Cmd Msg
deleteCoto cotoId =
    Http.send
        CotoDeleted
        ("/api/cotos/" ++ cotoId |> Utils.delete)
