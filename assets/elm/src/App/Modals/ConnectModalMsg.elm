module App.Modals.ConnectModalMsg exposing (Msg(..))

import Http
import App.Types.Post exposing (Post)
import App.Types.Graph exposing (Direction)


type Msg
    = ReverseDirection
    | PostAndConnectToSelection String (Maybe String) Direction
    | PostedAndConnectToSelection Int Direction (Result Http.Error Post)
