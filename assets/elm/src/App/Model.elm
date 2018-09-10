module App.Model exposing (..)

import Dict
import Set exposing (Set)
import Json.Encode exposing (Value)
import Json.Decode as Decode
import Random.Pcg
import Uuid
import Util.HttpUtil exposing (ClientId(ClientId))
import App.Route exposing (Route)
import App.ActiveViewOnMobile exposing (ActiveViewOnMobile(..))
import App.Types.Coto exposing (Coto, CotoId, ElementId, Cotonoma, CotonomaKey, CotoSelection)
import App.Types.Amishi exposing (Amishi, AmishiId, Presences)
import App.Types.Session exposing (Session)
import App.Types.Graph exposing (Direction(..), Graph, PinnedCotosView(..))
import App.Types.Timeline exposing (Timeline)
import App.Types.Traversal exposing (Traversals)
import App.Types.SearchResults exposing (SearchResults)
import App.Submodels.Context
import App.Submodels.LocalCotos
import App.Submodels.Modals exposing (Modal(..), Confirmation)
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
    , activeViewOnMobile : ActiveViewOnMobile
    , navigationToggled : Bool
    , navigationOpen : Bool
    , presences : Presences
    , modals : List Modal
    , confirmation : Confirmation
    , searchInputFocus : Bool
    , editorModal : App.Modals.EditorModal.Model
    , cotoMenuModal : Maybe App.Modals.CotoMenuModal.Model
    , cotoModal : Maybe App.Modals.CotoModal.Model
    , connectModal : Maybe App.Modals.ConnectModal.Model
    , signinModal : App.Modals.SigninModal.Model
    , inviteModal : App.Modals.InviteModal.Model
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
    , importModal : App.Modals.ImportModal.Model
    , pinnedCotosView : PinnedCotosView
    }


initModel : Int -> Route -> Model
initModel seed route =
    { route = route
    , clientId = generateClientId seed
    , session = Nothing
    , cotonoma = Nothing
    , cotonomaLoading = False
    , elementFocus = Nothing
    , contentOpenElements = Set.empty
    , reorderModeElements = Set.empty
    , cotoFocus = Nothing
    , selection = []
    , deselecting = Set.empty
    , activeViewOnMobile = TimelineView
    , navigationToggled = False
    , navigationOpen = False
    , presences = Dict.empty
    , modals = []
    , confirmation = App.Submodels.Modals.defaultConfirmation
    , searchInputFocus = False
    , editorModal = App.Modals.EditorModal.defaultModel
    , cotoMenuModal = Nothing
    , cotoModal = Nothing
    , connectModal = Nothing
    , signinModal = App.Modals.SigninModal.initModel False
    , inviteModal = App.Modals.InviteModal.defaultModel
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
    , importModal = App.Modals.ImportModal.defaultModel
    , pinnedCotosView = DocumentView
    }


generateClientId : Int -> ClientId
generateClientId seed =
    Random.Pcg.initialSeed seed
        |> Random.Pcg.step Uuid.uuidGenerator
        |> \( uuid, _ ) -> ClientId (Uuid.toString uuid)


setConfig : ( String, Value ) -> Model -> Model
setConfig ( key, value ) model =
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


getSelectedCotos : Model -> List Coto
getSelectedCotos model =
    model.selection
        |> List.filterMap (\cotoId -> App.Submodels.LocalCotos.getCoto cotoId model)
        |> List.reverse


deleteCoto : Coto -> Model -> Model
deleteCoto coto model =
    { model | traversals = App.Types.Traversal.closeTraversal coto.id model.traversals }
        |> App.Submodels.LocalCotos.deleteCoto coto
        |> App.Submodels.Context.deleteSelection coto.id


openTraversal : CotoId -> Model -> Model
openTraversal cotoId model =
    { model
        | graph =
            if App.Types.Graph.member cotoId model.graph then
                model.graph
            else
                case App.Submodels.LocalCotos.getCoto cotoId model of
                    Nothing ->
                        model.graph

                    Just coto ->
                        App.Types.Graph.addCoto coto model.graph
        , traversals =
            App.Types.Traversal.openTraversal cotoId model.traversals
        , activeViewOnMobile = TraversalsView
    }


closeSelectionColumnIfEmpty : Model -> Model
closeSelectionColumnIfEmpty model =
    if List.isEmpty model.selection then
        { model | cotoSelectionColumnOpen = False }
    else
        model


areTimelineAndGraphLoaded : Model -> Bool
areTimelineAndGraphLoaded model =
    (not model.timeline.loading) && (not model.loadingGraph)


isTimelineReady : Model -> Bool
isTimelineReady model =
    (areTimelineAndGraphLoaded model)
        && (not model.timeline.initializingScrollPos)
