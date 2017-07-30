module App.Types exposing (..)

import Dict
import App.Types.Amishi exposing (..)
import App.Types.Coto exposing (CotoId, Cotonoma, CotonomaKey)


type Route
    = HomeRoute
    | CotonomaRoute CotonomaKey
    | NotFoundRoute


type ViewInMobile
    = TimelineView
    | PinnedView
    | TraversalsView
    | SelectionView


type alias MemberConnCounts = Dict.Dict AmishiId Int
