module App.Types exposing (..)

import Dict
import App.Types.Amishi exposing (..)


type ViewInMobile
    = TimelineView
    | PinnedView
    | TraversalsView
    | SelectionView


type alias MemberConnCounts = Dict.Dict AmishiId Int
