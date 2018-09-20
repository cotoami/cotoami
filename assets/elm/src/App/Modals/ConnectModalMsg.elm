module App.Modals.ConnectModalMsg exposing (Msg(..))

import Http
import App.Types.Coto exposing (Coto, CotoContent)
import App.Types.Post exposing (Post)
import App.Types.Graph exposing (Direction)


type Msg
    = ReverseDirection
    | Connect Coto (List Coto) Direction
    | PostAndConnectToSelection CotoContent Direction
    | PostedAndConnectToSelection Int Direction (Result Http.Error Post)
