module App.Messages exposing (Msg(..))

import App.Modals.ConnectModalMsg
import App.Modals.ConnectionModalMsg
import App.Modals.CotoMenuModalMsg
import App.Modals.EditorModalMsg
import App.Modals.ImportModalMsg
import App.Modals.InviteModalMsg
import App.Modals.SigninModalMsg
import App.Modals.TimelineFilterModalMsg
import App.Ports.ImportFile exposing (ImportFile)
import App.Server.Pagination exposing (PaginatedList)
import App.Submodels.NarrowViewport exposing (ActiveView)
import App.Types.Connection exposing (Connection, Reordering)
import App.Types.Coto exposing (Coto, CotoContent, CotoId, Cotonoma, CotonomaKey, ElementId)
import App.Types.Graph exposing (Graph)
import App.Types.Post exposing (Post)
import App.Types.Session exposing (Session)
import App.Types.Watch exposing (Watch)
import App.Views.AppHeaderMsg
import App.Views.CotoSelectionMsg
import App.Views.CotoToolbarMsg
import App.Views.FlowMsg
import App.Views.ReorderMsg
import App.Views.StockMsg
import App.Views.TraversalsMsg
import Http
import Json.Encode exposing (Value)
import Keyboard exposing (..)
import Navigation exposing (Location)


type Msg
    = NoOp
    | LocalStorageItemFetched ( String, Value )
    | KeyDown KeyCode
    | CloseModal
    | Confirm Msg
    | AppClick
    | OnLocationChange Location
    | ToggleNavInNarrowViewport
    | ToggleNavInWideViewport
    | ToggleFlowInWideViewport
    | SwitchViewInNarrowViewport ActiveView
    | MoveToHome
    | CotonomaPresenceState Value
    | CotonomaPresenceDiff Value
    | SessionFetched (Result Http.Error Session)
    | HomePostsFetched (Result Http.Error (PaginatedList Post))
    | CotonomaPostsFetched (Result Http.Error ( Cotonoma, PaginatedList Post ))
    | CotonomasFetched (Result Http.Error ( List Cotonoma, List Cotonoma ))
    | SubCotonomasFetched (Result Http.Error (List Cotonoma))
    | GraphFetched (Result Http.Error Graph)
    | LoadSubgraph CotonomaKey
    | SubgraphFetched CotonomaKey (Result Http.Error Graph)
    | SelectImportFile
      --
      -- Search
      --
    | SearchInputFocusChanged Bool
    | SearchInput String
    | Search
    | SearchResultsFetched (Result Http.Error (List Post))
      --
      -- Coto
      --
    | CotoClick ElementId CotoId
    | CotoMouseEnter ElementId CotoId
    | CotoMouseLeave ElementId CotoId
    | SelectCoto Coto
    | OpenTraversal CotoId
    | CotonomaClick CotonomaKey
    | ToggleCotoContent ElementId
    | ConfirmDeleteCoto CotoId
    | DeleteCotoInServerSide CotoId
    | DeleteCotoInClientSide CotoId
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
    | SetReorderMode Reordering
    | CloseReorderMode
    | Watch CotonomaKey
    | Unwatch CotonomaKey
    | WatchlistUpdated (Result Http.Error (List Watch))
    | WatchlistOnCotonomaLoad Cotonoma (Result Http.Error (List Watch))
    | WatchTimestampUpdated (Result Http.Error Watch)
    | GraphChanged
      --
      -- Pushed
      --
    | PostPushed Value
    | DeletePushed Value
    | CotoUpdatePushed Value
    | CotonomatizePushed Value
    | CotonomaUpdatePushed Value
    | ConnectPushed Value
    | DisconnectPushed Value
    | ConnectionUpdatePushed Value
    | ReorderPushed Value
      --
      -- Open modal
      --
    | ClearModals
    | CloseActiveModal
    | OpenConfirmModal String Msg
    | OpenAppInfoModal
    | OpenSigninModal
    | OpenProfileModal
    | OpenCotoMenuModal Coto
    | OpenNewEditorModal
    | OpenNewEditorModalWithSourceCoto Coto
    | OpenEditorModal Coto
    | OpenCotoModal Coto
    | OpenImportModal ImportFile
    | OpenTimelineFilterModal
    | OpenConnectModalByCoto Coto
    | OpenConnectModalByNewPost CotoContent Msg
    | OpenConnectionModal Connection Coto Coto
    | OpenInviteModal
      --
      -- Sub components
      --
    | AppHeaderMsg App.Views.AppHeaderMsg.Msg
    | FlowMsg App.Views.FlowMsg.Msg
    | StockMsg App.Views.StockMsg.Msg
    | TraversalsMsg App.Views.TraversalsMsg.Msg
    | CotoSelectionMsg App.Views.CotoSelectionMsg.Msg
    | CotoToolbarMsg App.Views.CotoToolbarMsg.Msg
    | ReorderMsg App.Views.ReorderMsg.Msg
    | SigninModalMsg App.Modals.SigninModalMsg.Msg
    | EditorModalMsg App.Modals.EditorModalMsg.Msg
    | CotoMenuModalMsg App.Modals.CotoMenuModalMsg.Msg
    | ConnectModalMsg App.Modals.ConnectModalMsg.Msg
    | ConnectionModalMsg App.Modals.ConnectionModalMsg.Msg
    | InviteModalMsg App.Modals.InviteModalMsg.Msg
    | ImportModalMsg App.Modals.ImportModalMsg.Msg
    | TimelineFilterModalMsg App.Modals.TimelineFilterModalMsg.Msg
