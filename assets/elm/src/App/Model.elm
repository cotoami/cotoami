module App.Model
    exposing
        ( Model
        , initModel
        , configure
        , deleteCoto
        , openTraversal
        , closeSelectionColumnIfEmpty
        )

import Dict
import Set exposing (Set)
import Json.Encode exposing (Value)
import Json.Decode as Decode
import Util.HttpUtil exposing (ClientId(ClientId))
import App.Route exposing (Route)
import App.Types.Coto exposing (Coto, CotoId, ElementId, Cotonoma, CotonomaKey, CotoSelection)
import App.Types.Amishi exposing (Amishi, AmishiId, Presences)
import App.Types.Session exposing (Session)
import App.Types.Graph exposing (Direction(..), Graph)
import App.Types.Timeline exposing (Timeline)
import App.Types.Traversal exposing (Traversals)
import App.Types.SearchResults exposing (SearchResults)
import App.Submodels.Context
import App.Submodels.LocalCotos
import App.Submodels.Modals exposing (Modal(..), Confirmation)
import App.Submodels.Traversals
import App.Views.ViewSwitchMsg exposing (ActiveView(..))
import App.Views.Stock
import App.Modals.SigninModal
import App.Modals.EditorModal
import App.Modals.InviteModal
import App.Modals.CotoMenuModal
import App.Modals.CotoModal
import App.Modals.ConnectModal
import App.Modals.ImportModal


type alias Model =
    { route : Route
    , clientId : ClientId
    , session : Maybe Session
    , cotonoma : Maybe Cotonoma
    , cotonomaLoading : Bool
    , elementFocus : Maybe ElementId
    , contentOpenElements : Set ElementId
    , reorderModeElements : Set ElementId
    , cotoFocus : Maybe CotoId
    , selection : CotoSelection
    , deselecting : Set CotoId
    , activeView : ActiveView
    , navigationToggled : Bool
    , navigationOpen : Bool
    , presences : Presences
    , confirmation : Confirmation
    , searchInputFocus : Bool
    , recentCotonomas : List Cotonoma
    , cotonomasLoading : Bool
    , subCotonomas : List Cotonoma
    , timeline : Timeline
    , searchResults : SearchResults
    , cotoSelectionColumnOpen : Bool
    , cotoSelectionTitle : String
    , graph : Graph
    , loadingGraph : Bool
    , traversals : Traversals
    , stockView : App.Views.Stock.Model
    , modals : List Modal
    , signinModal : App.Modals.SigninModal.Model
    , editorModal : App.Modals.EditorModal.Model
    , cotoMenuModal : Maybe App.Modals.CotoMenuModal.Model
    , cotoModal : Maybe App.Modals.CotoModal.Model
    , connectModal : App.Modals.ConnectModal.Model
    , importModal : App.Modals.ImportModal.Model
    , inviteModal : App.Modals.InviteModal.Model
    }


initModel : Int -> Route -> Model
initModel seed route =
    { route = route
    , clientId = App.Submodels.Context.generateClientId seed
    , session = Nothing
    , cotonoma = Nothing
    , cotonomaLoading = False
    , elementFocus = Nothing
    , contentOpenElements = Set.empty
    , reorderModeElements = Set.empty
    , cotoFocus = Nothing
    , selection = []
    , deselecting = Set.empty
    , activeView = FlowView
    , navigationToggled = False
    , navigationOpen = False
    , presences = Dict.empty
    , confirmation = App.Submodels.Modals.defaultConfirmation
    , searchInputFocus = False
    , recentCotonomas = []
    , cotonomasLoading = False
    , subCotonomas = []
    , timeline = App.Types.Timeline.defaultTimeline
    , searchResults = App.Types.SearchResults.defaultSearchResults
    , cotoSelectionColumnOpen = False
    , cotoSelectionTitle = ""
    , graph = App.Types.Graph.defaultGraph
    , loadingGraph = False
    , traversals = App.Types.Traversal.defaultTraversals
    , stockView = App.Views.Stock.defaultModel
    , modals = []
    , signinModal = App.Modals.SigninModal.initModel False
    , editorModal = App.Modals.EditorModal.defaultModel
    , cotoMenuModal = Nothing
    , cotoModal = Nothing
    , connectModal = App.Modals.ConnectModal.defaultModel
    , importModal = App.Modals.ImportModal.defaultModel
    , inviteModal = App.Modals.InviteModal.defaultModel
    }


configure : ( String, Value ) -> Model -> Model
configure ( key, value ) model =
    case key of
        "timeline.filter" ->
            value
                |> Decode.decodeValue (Decode.maybe App.Types.Timeline.decodeFilter)
                |> Result.withDefault Nothing
                |> Maybe.map
                    (\filter ->
                        { model | timeline = App.Types.Timeline.setFilter filter model.timeline }
                    )
                |> Maybe.withDefault model

        _ ->
            model


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


closeSelectionColumnIfEmpty : Model -> Model
closeSelectionColumnIfEmpty model =
    if List.isEmpty model.selection then
        { model | cotoSelectionColumnOpen = False }
    else
        model
