module App.Model exposing
    ( Model
    , deleteCoto
    , initModel
    , openTraversal
    )

import App.I18n.Keys exposing (TextKey)
import App.I18n.Translate
import App.Modals.ConnectModal
import App.Modals.ConnectionModal
import App.Modals.CotoMenuModal
import App.Modals.CotoModal
import App.Modals.EditorModal
import App.Modals.ImportModal
import App.Modals.InviteModal
import App.Modals.SigninModal
import App.Route exposing (Route)
import App.Submodels.Context
import App.Submodels.LocalCotos
import App.Submodels.Modals exposing (Confirmation, Modal(..))
import App.Submodels.Traversals
import App.Types.Amishi exposing (Amishi, AmishiId, Presences)
import App.Types.Connection exposing (Direction(..), Reordering)
import App.Types.Coto exposing (Coto, CotoId, CotoSelection, Cotonoma, CotonomaKey, ElementId)
import App.Types.Graph exposing (Graph)
import App.Types.SearchResults exposing (SearchResults)
import App.Types.Session exposing (Session)
import App.Types.Timeline exposing (Timeline)
import App.Types.Traversal exposing (Traversals)
import App.Types.Watch exposing (Watch)
import App.Views.CotoSelection
import App.Views.Flow
import App.Views.Stock
import App.Views.ViewSwitchMsg exposing (ActiveView(..))
import Dict
import Set exposing (Set)
import Utils.HttpUtil exposing (ClientId(ClientId))


type alias Model =
    { route : Route
    , clientId : ClientId
    , lang : String
    , i18nText : TextKey -> String
    , session : Maybe Session
    , activeView : ActiveView
    , cotonoma : Maybe Cotonoma
    , cotonomaLoading : Bool
    , watchStateOnCotonomaLoad : Maybe Watch
    , elementFocus : Maybe ElementId
    , contentOpenElements : Set ElementId
    , reordering : Maybe Reordering
    , cotoFocus : Maybe CotoId
    , selection : CotoSelection
    , deselecting : Set CotoId
    , navigationToggled : Bool
    , navigationOpen : Bool
    , presences : Presences
    , confirmation : Maybe Confirmation
    , searchInputFocus : Bool
    , globalCotonomas : List Cotonoma
    , recentCotonomas : List Cotonoma
    , cotonomasLoading : Bool
    , subCotonomas : List Cotonoma
    , watchlist : List Watch
    , watchlistLoading : Bool
    , watchUpdating : Bool
    , timeline : Timeline
    , searchResults : SearchResults
    , graph : Graph
    , loadingGraph : Bool
    , traversals : Traversals
    , flowView : App.Views.Flow.Model
    , stockView : App.Views.Stock.Model
    , selectionView : App.Views.CotoSelection.Model
    , modals : List Modal
    , signinModal : App.Modals.SigninModal.Model
    , editorModal : App.Modals.EditorModal.Model
    , cotoMenuModal : Maybe App.Modals.CotoMenuModal.Model
    , cotoModal : Maybe App.Modals.CotoModal.Model
    , connectModal : App.Modals.ConnectModal.Model
    , connectionModal : Maybe App.Modals.ConnectionModal.Model
    , importModal : Maybe App.Modals.ImportModal.Model
    , inviteModal : App.Modals.InviteModal.Model
    }


initModel : Int -> String -> Route -> Model
initModel seed lang route =
    { route = route
    , clientId = App.Submodels.Context.generateClientId seed
    , lang = lang
    , i18nText = App.I18n.Translate.text lang
    , session = Nothing
    , activeView = FlowView
    , cotonoma = Nothing
    , cotonomaLoading = False
    , watchStateOnCotonomaLoad = Nothing
    , elementFocus = Nothing
    , contentOpenElements = Set.empty
    , reordering = Nothing
    , cotoFocus = Nothing
    , selection = []
    , deselecting = Set.empty
    , navigationToggled = False
    , navigationOpen = False
    , presences = Dict.empty
    , confirmation = Nothing
    , searchInputFocus = False
    , globalCotonomas = []
    , recentCotonomas = []
    , cotonomasLoading = False
    , subCotonomas = []
    , watchlist = []
    , watchlistLoading = False
    , watchUpdating = False
    , timeline = App.Types.Timeline.defaultTimeline
    , searchResults = App.Types.SearchResults.defaultSearchResults
    , graph = App.Types.Graph.defaultGraph
    , loadingGraph = False
    , traversals = App.Types.Traversal.defaultTraversals
    , flowView = App.Views.Flow.defaultModel
    , stockView = App.Views.Stock.defaultModel
    , selectionView = App.Views.CotoSelection.defaultModel
    , modals = []
    , signinModal = App.Modals.SigninModal.defaultModel
    , editorModal = App.Modals.EditorModal.defaultModel
    , cotoMenuModal = Nothing
    , cotoModal = Nothing
    , connectModal = App.Modals.ConnectModal.defaultModel
    , connectionModal = Nothing
    , importModal = Nothing
    , inviteModal = App.Modals.InviteModal.defaultModel
    }


deleteCoto : Coto -> Model -> Model
deleteCoto coto model =
    model
        |> App.Submodels.LocalCotos.deleteCoto coto
        |> App.Submodels.Context.deleteSelection coto.id
        |> App.Submodels.Traversals.closeTraversal coto.id


openTraversal : CotoId -> Model -> Model
openTraversal cotoId model =
    model
        |> App.Submodels.LocalCotos.incorporateLocalCotoInGraph cotoId
        |> App.Submodels.Traversals.openTraversal cotoId
