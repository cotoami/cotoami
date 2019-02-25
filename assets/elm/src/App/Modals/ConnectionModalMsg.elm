module App.Modals.ConnectionModalMsg exposing (Msg(..))

import App.Types.Amishi exposing (Amishi)
import App.Types.Connection exposing (Connection)
import Http


type Msg
    = Init
    | AmishiFetched (Result Http.Error Amishi)
    | Save
    | ConnectionUpdated (Result Http.Error Connection)
