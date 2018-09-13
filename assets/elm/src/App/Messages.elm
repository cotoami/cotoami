module App.Messages exposing (Msg(..))

import Http
import Json.Encode exposing (Value)
import Keyboard exposing (..)
import Navigation exposing (Location)
import App.ActiveViewOnMobile exposing (ActiveViewOnMobile)
import App.Types.Coto exposing (Coto, ElementId, CotoId, Cotonoma, CotonomaKey)
import App.Types.Post exposing (Post, PaginatedPosts)
import App.Types.Session exposing (Session)
import App.Types.Graph exposing (Direction, Graph, PinnedCotosView)
import App.Types.Traversal exposing (Traversal)
import App.Views.FlowMsg
import App.Views.TraversalsMsg
import App.Modals.SigninModalMsg
import App.Modals.EditorModalMsg
import App.Modals.CotoMenuModalMsg
import App.Modals.ConnectModalMsg
import App.Modals.InviteModalMsg
import App.Modals.ImportModalMsg
import App.Modals.TimelineFilterModalMsg


type Msg
    = NoOp
    | LocalStorageItemFetched ( String, Value )
    | KeyDown KeyCode
    | AppClick
    | OnLocationChange Location
    | NavigationToggle
    | SwitchViewOnMobile ActiveViewOnMobile
    | ToggleTimeline
    | HomeClick
    | CotonomaPresenceState Value
    | CotonomaPresenceDiff Value
    | SessionFetched (Result Http.Error Session)
    | HomePostsFetched (Result Http.Error PaginatedPosts)
    | CotonomaPostsFetched (Result Http.Error ( Cotonoma, PaginatedPosts ))
    | CotonomasFetched (Result Http.Error (List Cotonoma))
    | SubCotonomasFetched (Result Http.Error (List Cotonoma))
    | GraphFetched (Result Http.Error Graph)
    | SubgraphFetched (Result Http.Error Graph)
      --
      -- Search
      --
    | SearchInputFocusChanged Bool
    | ClearQuickSearchInput
    | QuickSearchInput String
    | SearchInput String
    | Search
    | SearchResultsFetched (Result Http.Error PaginatedPosts)
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
      -- PinnedCotos
      --
    | SwitchPinnedCotosView PinnedCotosView
    | RenderGraph
    | ResizeGraph
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
    | ConnectPushed Value
    | DisconnectPushed Value
    | ReorderPushed Value
    | PostPushed Value
      --
      -- Sub components
      --
    | FlowMsg App.Views.FlowMsg.Msg
    | TraversalsMsg App.Views.TraversalsMsg.Msg
    | SigninModalMsg App.Modals.SigninModalMsg.Msg
    | EditorModalMsg App.Modals.EditorModalMsg.Msg
    | CotoMenuModalMsg App.Modals.CotoMenuModalMsg.Msg
    | ConnectModalMsg App.Modals.ConnectModalMsg.Msg
    | InviteModalMsg App.Modals.InviteModalMsg.Msg
    | ImportModalMsg App.Modals.ImportModalMsg.Msg
    | TimelineFilterModalMsg App.Modals.TimelineFilterModalMsg.Msg
