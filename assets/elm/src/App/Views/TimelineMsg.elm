module App.Views.TimelineMsg exposing (..)

import App.Types.Timeline exposing (TimelineView)


type Msg
    = SwitchView TimelineView
    | LoadMorePosts
    | EditorFocus
    | EditorInput String
