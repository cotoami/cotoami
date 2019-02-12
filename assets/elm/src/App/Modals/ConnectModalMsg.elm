module App.Modals.ConnectModalMsg exposing (Msg(..))

import App.Types.Connection exposing (Direction)
import App.Types.Coto exposing (Coto, CotoContent)
import App.Types.Post exposing (Post)
import Http


type Msg
    = ReverseDirection
    | Connect Coto (List Coto) Direction
    | PostAndConnectToSelection CotoContent Direction
    | PostedAndConnectToSelection Int Direction (Result Http.Error Post)
