module App.Views.ReorderMsg exposing (Msg(..))

import App.Types.Coto exposing (CotoId)
import Http


type Msg
    = SwapOrder (Maybe CotoId) Int Int
    | MoveToFirst (Maybe CotoId) Int
    | MoveToLast (Maybe CotoId) Int
    | ConnectionsReordered (Result Http.Error String)
