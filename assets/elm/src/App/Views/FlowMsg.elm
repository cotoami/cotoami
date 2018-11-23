module App.Views.FlowMsg exposing (Msg(..), TimelineView(..))

import Http
import Utils.Keyboard.Event exposing (KeyboardEvent)
import Utils.EventUtil exposing (ScrollPos)
import App.Types.Coto exposing (CotoContent)
import App.Types.Post exposing (Post)


type TimelineView
    = StreamView
    | TileView


type Msg
    = ToggleFlow
    | TimelineScrollPosInitialized
    | ImageLoaded
    | SwitchView TimelineView
    | LoadMorePosts
    | EditorFocus
    | EditorInput String
    | EditorKeyDown KeyboardEvent
    | Post
    | Posted Int (Result Http.Error Post)
    | ConfirmPostAndConnect CotoContent
    | Scroll ScrollPos
