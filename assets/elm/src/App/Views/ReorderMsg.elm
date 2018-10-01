module App.Views.ReorderMsg exposing (Msg(..))

import Http
import App.Types.Coto exposing (CotoId)


type Msg
    = SwapOrder (Maybe CotoId) Int Int
    | MoveToFirst (Maybe CotoId) Int
    | MoveToLast (Maybe CotoId) Int
    | ConnectionsReordered (Result Http.Error String)
