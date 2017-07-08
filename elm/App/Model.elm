module App.Model exposing (..)

import Set
import Dict
import Uuid
import Random.Pcg exposing (initialSeed, step)
import Exts.Maybe exposing (isNothing)
import App.Types exposing (..)
import App.Graph exposing (Graph, initGraph, addConnections)
import Components.ConfirmModal.Model
import Components.SigninModal
import Components.ProfileModal
import Components.Timeline.Model
import Components.CotoModal
import Components.CotonomaModal.Model
import Components.Traversals.Model exposing (Description)


type alias Model =
    { route : Route
    , context : Context
    , viewInMobile : ViewInMobile
    , navigationToggled : Bool
    , navigationOpen : Bool
    , members : List Amishi
    , memberPresences : MemberConnCounts
    , confirmModal : Components.ConfirmModal.Model.Model
    , signinModal : Components.SigninModal.Model
    , profileModal : Components.ProfileModal.Model
    , cotoModal : Components.CotoModal.Model
    , recentCotonomas : List Cotonoma
    , cotonomasLoading : Bool
    , subCotonomas : List Cotonoma
    , timeline : Components.Timeline.Model.Model
    , cotoSelectionTitle : String
    , connectMode : Bool
    , connectingTo : Maybe Int
    , connectModalOpen : Bool
    , cotonomaModal : Components.CotonomaModal.Model.Model
    , graph : Graph
    , traversals : Components.Traversals.Model.Model
    }


initModel : Int -> Route -> Model
initModel seed route =
    { route = route
    , context =
        { clientId =
            initialSeed seed
                |> step Uuid.uuidGenerator
                |> \( uuid, _ ) -> Uuid.toString uuid
        , session = Nothing
        , cotonoma = Nothing
        , focus = Nothing
        , selection = []
        , deselecting = Set.empty
        , ctrlDown = False
        }
    , viewInMobile = TimelineView
    , navigationToggled = False
    , navigationOpen = False
    , members = []
    , memberPresences = Dict.empty
    , confirmModal = Components.ConfirmModal.Model.initModel
    , signinModal = Components.SigninModal.initModel
    , profileModal = Components.ProfileModal.initModel
    , cotoModal = Components.CotoModal.initModel
    , recentCotonomas = []
    , cotonomasLoading = False
    , subCotonomas = []
    , timeline = Components.Timeline.Model.initModel
    , cotoSelectionTitle = ""
    , connectMode = False
    , connectingTo = Nothing
    , connectModalOpen = False
    , cotonomaModal = Components.CotonomaModal.Model.initModel
    , graph = initGraph
    , traversals = Components.Traversals.Model.initModel
    }


getCoto : Int -> Model -> Maybe Coto
getCoto cotoId model =
    case Dict.get cotoId model.graph.cotos of
        Nothing ->
            Components.Timeline.Model.getCoto cotoId model.timeline
        Just coto ->
            Just coto


getSelectedCoto : Model -> List Coto
getSelectedCoto model =
    List.filterMap
        (\cotoId -> getCoto cotoId model)
        model.context.selection


openSigninModal : Model -> Model
openSigninModal model =
    { model
    | signinModal =
        model.signinModal
            |> \modal -> { modal | open = True }
    }


isPresent : Int -> MemberConnCounts -> Bool
isPresent amishiId memberPresences =
    (Dict.get amishiId memberPresences |> Maybe.withDefault 0) > 0


isNavigationEmpty : Model -> Bool
isNavigationEmpty model =
    (isNothing model.context.cotonoma)
        && (List.isEmpty model.recentCotonomas)
        && (List.isEmpty model.subCotonomas)


isStockEmpty : Model -> Bool
isStockEmpty model =
      List.isEmpty model.graph.rootConnections


getOwnerAndMembers : Model -> List Amishi
getOwnerAndMembers model =
    case model.context.cotonoma of
        Nothing -> []
        Just cotonoma ->
            case cotonoma.owner of
                Nothing -> model.members
                Just owner -> owner :: model.members


openTraversal : Description -> CotoId -> Model -> Model
openTraversal description cotoId model =
    { model
    | traversals =
          Components.Traversals.Model.openTraversal
              description
              cotoId
              model.traversals
    , viewInMobile = TraversalsView
    }


connect : Coto -> List Coto -> Model -> Model
connect startCoto endCotos model =
    { model
    | graph = model.graph |> addConnections startCoto endCotos
    , context = model.context |> \context -> { context | selection = [] }
    , connectMode = False
    , connectModalOpen = False
    }
        |> openTraversal Components.Traversals.Model.Connected startCoto.id
