module App.Views.TimelineMsg exposing (..)

import Http
import Util.Keyboard.Event exposing (KeyboardEvent)
import App.Types.Post exposing (Post)
import App.Types.Timeline exposing (TimelineView)


type Msg
    = SwitchView TimelineView
    | LoadMorePosts
    | EditorFocus
    | EditorInput String
    | EditorKeyDown KeyboardEvent
    | Post
    | Posted Int (Result Http.Error Post)
    | ConfirmPostAndConnect String (Maybe String)
