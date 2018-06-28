module App.Messages exposing (Msg(..))

import Http
import Json.Encode exposing (Value)
import Keyboard exposing (..)
import Navigation exposing (Location)
import Util.Keyboard.Event exposing (KeyboardEvent)
import App.ActiveViewOnMobile exposing (ActiveViewOnMobile)
import App.Types.Coto exposing (Coto, ElementId, CotoId, Cotonoma, CotonomaKey, CotonomaStats)
import App.Types.Post exposing (Post, PaginatedPosts)
import App.Types.Session exposing (Session)
import App.Types.Graph exposing (Direction, Graph, PinnedCotosView)
import App.Types.Timeline exposing (TimelineView)
import App.Types.Traversal exposing (Traversal)
import App.Modals.SigninModalMsg
import App.Modals.EditorModalMsg
import App.Modals.InviteModalMsg
import App.Modals.ImportModalMsg
import App.Modals.TimelineFilterModalMsg


type Msg
    = NoOp
    | KeyDown KeyCode
    | AppClick
    | OnLocationChange Location
    | NavigationToggle
    | SwitchViewOnMobile ActiveViewOnMobile
    | ToggleTimeline
    | HomeClick
    | CotonomaPresenceState Value
    | CotonomaPresenceDiff Value
    | SearchInputFocusChanged Bool
    | ClearQuickSearchInput
    | QuickSearchInput String
    | SearchInput String
    | Search
    | SearchResultsFetched (Result Http.Error PaginatedPosts)
      --
      -- Fetched
      --
    | SessionFetched (Result Http.Error Session)
    | CotonomasFetched (Result Http.Error ( List Cotonoma, List Cotonoma ))
    | SubCotonomasFetched (Result Http.Error (List Cotonoma))
    | CotonomaFetched (Result Http.Error ( Cotonoma, PaginatedPosts ))
    | CotonomaStatsFetched (Result Http.Error CotonomaStats)
    | GraphFetched (Result Http.Error Graph)
    | SubgraphFetched (Result Http.Error Graph)
      --
      -- Modal
      --
    | CloseModal
    | Confirm
    | OpenSigninModal
    | OpenNewEditorModal
    | OpenNewEditorModalWithSourceCoto Coto
    | OpenInviteModal
    | OpenProfileModal
    | OpenCotoMenuModal Coto
    | OpenEditorModal Coto
    | OpenCotoModal Coto
    | OpenImportModal
    | OpenTimelineFilterModal
      --
      -- Coto
      --
    | CotoClick ElementId CotoId
    | CotoMouseEnter ElementId CotoId
    | CotoMouseLeave ElementId CotoId
    | SelectCoto CotoId
    | OpenTraversal CotoId
    | CotonomaClick CotonomaKey
    | ToggleCotoContent ElementId
    | ConfirmDeleteCoto Coto
    | DeleteCotoInServerSide Coto
    | DeleteCotoInClientSide Coto
    | CotoDeleted (Result Http.Error String)
    | CotoUpdated (Result Http.Error Coto)
    | ConfirmCotonomatize Coto
    | Cotonomatize CotoId
    | Cotonomatized (Result Http.Error Coto)
    | PinCoto CotoId
    | PinCotoToMyHome CotoId
    | CotoPinned (Result Http.Error String)
    | ConfirmUnpinCoto CotoId
    | UnpinCoto CotoId
    | CotoUnpinned (Result Http.Error String)
    | ConfirmConnect CotoId Direction
    | ReverseDirection
    | Connect Coto (List Coto) Direction
    | Connected (Result Http.Error (List String))
    | ConfirmDeleteConnection ( CotoId, CotoId )
    | DeleteConnection ( CotoId, CotoId )
    | ConnectionDeleted (Result Http.Error String)
    | ToggleReorderMode ElementId
    | SwapOrder (Maybe CotoId) Int Int
    | MoveToFirst (Maybe CotoId) Int
    | MoveToLast (Maybe CotoId) Int
    | ConnectionsReordered (Result Http.Error String)
      --
      -- Cotonoma
      --
    | PinOrUnpinCotonoma CotonomaKey Bool
    | CotonomaPinnedOrUnpinned (Result Http.Error String)
    | LoadMorePostsInCotonoma CotonomaKey
      --
      -- Timeline
      --
    | SwitchTimelineView TimelineView
    | PostsFetched (Result Http.Error PaginatedPosts)
    | LoadMorePosts
    | ImageLoaded
    | EditorFocus
    | EditorInput String
    | EditorKeyDown KeyboardEvent
    | Post
    | Posted Int (Result Http.Error Post)
    | ConfirmPostAndConnect String (Maybe String)
    | PostAndConnectToSelection String (Maybe String)
    | PostedAndConnectToSelection Int (Result Http.Error Post)
    | PostedAndConnectToCoto Int Coto (Result Http.Error Post)
    | CotonomaPosted Int (Result Http.Error Post)
    | TimelineScrollPosInitialized
      --
      -- PinnedCotos
      --
    | SwitchPinnedCotosView PinnedCotosView
    | RenderGraph
    | ResizeGraph
      --
      -- Traversals
      --
    | Traverse Traversal CotoId Int
    | TraverseToParent Traversal CotoId
    | CloseTraversal CotoId
    | SwitchTraversal Int
      --
      -- CotoSelection
      --
    | DeselectingCoto CotoId
    | DeselectCoto
    | ClearSelection
    | CotoSelectionColumnToggle
      --
      -- Pushed
      --
    | UpdatePushed Value
    | DeletePushed Value
    | CotonomatizePushed Value
    | CotonomaPushed Value
    | ConnectPushed Value
    | DisconnectPushed Value
    | ReorderPushed Value
    | PostPushed Value
      --
      -- Sub components
      --
    | SigninModalMsg App.Modals.SigninModalMsg.Msg
    | EditorModalMsg App.Modals.EditorModalMsg.Msg
    | InviteModalMsg App.Modals.InviteModalMsg.Msg
    | ImportModalMsg App.Modals.ImportModalMsg.Msg
    | TimelineFilterModalMsg App.Modals.TimelineFilterModalMsg.Msg
