module App.Modals.ConnectionModalMsg exposing (Msg(..))

import App.Types.Amishi exposing (Amishi)
import Http


type Msg
    = Init
    | AmishiFetched (Result Http.Error Amishi)
