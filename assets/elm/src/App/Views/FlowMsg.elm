module App.Views.FlowMsg exposing (Msg(..), TimelineView(..))

import App.Types.Post exposing (Post)
import Http
import Utils.EventUtil exposing (ScrollPos)
import Utils.Keyboard.Event exposing (KeyboardEvent)


type TimelineView
    = StreamView
    | TileView


type Msg
    = ToggleFlow
    | TimelineScrollPosInitialized Float
    | ImageLoaded
    | SwitchView TimelineView
    | LoadMorePosts
    | EditorFocus
    | EditorInput String
    | EditorKeyDown KeyboardEvent
    | Post
    | Posted Int (Result Http.Error Post)
    | PostedByConnectModal
    | Scroll ScrollPos
