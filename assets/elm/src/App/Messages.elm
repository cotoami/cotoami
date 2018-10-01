module App.Messages exposing (Msg(..))

import Http
import Json.Encode exposing (Value)
import Keyboard exposing (..)
import Navigation exposing (Location)
import App.Types.Coto exposing (Coto, ElementId, CotoId, Cotonoma, CotonomaKey)
import App.Types.Post exposing (Post, PaginatedPosts)
import App.Types.Session exposing (Session)
import App.Types.Graph exposing (Direction, Graph)
import App.Views.AppHeaderMsg
import App.Views.ViewSwitchMsg
import App.Views.FlowMsg
import App.Views.StockMsg
import App.Views.TraversalsMsg
import App.Views.CotoSelectionMsg
import App.Views.CotoToolbarMsg
import App.Modals.SigninModalMsg
import App.Modals.ProfileModalMsg
import App.Modals.EditorModalMsg
import App.Modals.CotoMenuModalMsg
import App.Modals.ConnectModalMsg
import App.Modals.InviteModalMsg
import App.Modals.ImportModalMsg
import App.Modals.TimelineFilterModalMsg
import App.Ports.ImportFile exposing (ImportFile)


type Msg
    = NoOp
    | LocalStorageItemFetched ( String, Value )
    | KeyDown KeyCode
    | CloseModal
    | Confirm
    | AppClick
    | OnLocationChange Location
    | NavigationToggle
    | MoveToHome
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
    | SearchInput String
    | Search
    | SearchResultsFetched (Result Http.Error PaginatedPosts)
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
    | Connected (Result Http.Error (List String))
    | DeleteConnection ( CotoId, CotoId )
    | ConnectionDeleted (Result Http.Error String)
    | ToggleReorderMode ElementId
    | SwapOrder (Maybe CotoId) Int Int
    | MoveToFirst (Maybe CotoId) Int
    | MoveToLast (Maybe CotoId) Int
    | ConnectionsReordered (Result Http.Error String)
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
    | AppHeaderMsg App.Views.AppHeaderMsg.Msg
    | ViewSwitchMsg App.Views.ViewSwitchMsg.Msg
    | FlowMsg App.Views.FlowMsg.Msg
    | StockMsg App.Views.StockMsg.Msg
    | TraversalsMsg App.Views.TraversalsMsg.Msg
    | CotoSelectionMsg App.Views.CotoSelectionMsg.Msg
    | CotoToolbarMsg App.Views.CotoToolbarMsg.Msg
    | SigninModalMsg App.Modals.SigninModalMsg.Msg
    | ProfileModalMsg App.Modals.ProfileModalMsg.Msg
    | OpenNewEditorModal
    | OpenNewEditorModalWithSourceCoto Coto
    | OpenEditorModal Coto
    | EditorModalMsg App.Modals.EditorModalMsg.Msg
    | CotoMenuModalMsg App.Modals.CotoMenuModalMsg.Msg
    | OpenCotoModal Coto
    | ConnectModalMsg App.Modals.ConnectModalMsg.Msg
    | InviteModalMsg App.Modals.InviteModalMsg.Msg
    | OpenImportModal ImportFile
    | ImportModalMsg App.Modals.ImportModalMsg.Msg
    | OpenTimelineFilterModal
    | TimelineFilterModalMsg App.Modals.TimelineFilterModalMsg.Msg
