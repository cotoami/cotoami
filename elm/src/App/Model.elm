module App.Model exposing (..)

import Dict
import Exts.Maybe exposing (isNothing)
import App.Route exposing (Route)
import App.ActiveViewOnMobile exposing (ActiveViewOnMobile(..))
import App.Types.Context exposing (..)
import App.Types.Coto exposing (Coto, CotoId, Cotonoma)
import App.Types.Amishi exposing (Amishi, AmishiId)
import App.Types.MemberPresences exposing (MemberPresences)
import App.Types.Graph exposing (Direction, Graph, defaultGraph)
import App.Types.Timeline exposing (Timeline, defaultTimeline)
import App.Types.Traversal exposing (Description, Traversals, defaultTraversals)
import App.Types.ProfileModal exposing (..)
import Components.ConfirmModal.Model
import Components.SigninModal
import Components.CotoModal
import Components.CotonomaModal.Model


type alias Model =
    { route : Route
    , context : Context
    , activeViewOnMobile : ActiveViewOnMobile
    , navigationToggled : Bool
    , navigationOpen : Bool
    , members : List Amishi
    , memberPresences : MemberPresences
    , confirmModal : Components.ConfirmModal.Model.Model
    , signinModal : Components.SigninModal.Model
    , profileModal : ProfileModal
    , cotoModal : Components.CotoModal.Model
    , recentCotonomas : List Cotonoma
    , cotonomasLoading : Bool
    , subCotonomas : List Cotonoma
    , timeline : Timeline
    , cotoSelectionColumnOpen : Bool
    , cotoSelectionTitle : String
    , connectingCotoId : Maybe CotoId
    , connectingDirection : Direction
    , cotonomaModal : Components.CotonomaModal.Model.Model
    , graph : Graph
    , traversals : Traversals
    }


initModel : Int -> Route -> Model
initModel seed route =
    { route = route
    , context = initContext seed
    , activeViewOnMobile = TimelineView
    , navigationToggled = False
    , navigationOpen = False
    , members = []
    , memberPresences = Dict.empty
    , confirmModal = Components.ConfirmModal.Model.initModel
    , signinModal = Components.SigninModal.initModel
    , profileModal = initProfileModel
    , cotoModal = Components.CotoModal.initModel
    , recentCotonomas = []
    , cotonomasLoading = False
    , subCotonomas = []
    , timeline = defaultTimeline
    , cotoSelectionColumnOpen = False
    , cotoSelectionTitle = ""
    , connectingCotoId = Nothing
    , connectingDirection = App.Types.Graph.Outbound
    , cotonomaModal = Components.CotonomaModal.Model.initModel
    , graph = defaultGraph
    , traversals = defaultTraversals
    }


getCoto : CotoId -> Model -> Maybe Coto
getCoto cotoId model =
    case Dict.get cotoId model.graph.cotos of
        Nothing ->
            App.Types.Timeline.getCoto cotoId model.timeline

        Just coto ->
            Just coto


getSelectedCotos : Model -> List Coto
getSelectedCotos model =
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
        Nothing ->
            []

        Just cotonoma ->
            case cotonoma.owner of
                Nothing ->
                    model.members

                Just owner ->
                    owner :: model.members


openTraversal : Description -> CotoId -> Model -> Model
openTraversal description cotoId model =
    { model
        | graph =
            if App.Types.Graph.member cotoId model.graph then
                model.graph
            else
                case getCoto cotoId model of
                    Nothing ->
                        model.graph

                    Just coto ->
                        App.Types.Graph.addCoto coto model.graph
        , traversals =
            App.Types.Traversal.openTraversal
                description
                cotoId
                model.traversals
        , activeViewOnMobile = TraversalsView
    }


connect : Direction -> List Coto -> Coto -> Model -> Model
connect direction objects subject model =
    { model
        | graph =
            case direction of
                App.Types.Graph.Outbound ->
                    App.Types.Graph.connectOneToMany subject objects model.graph

                App.Types.Graph.Inbound ->
                    App.Types.Graph.connectManyToOne objects subject model.graph
        , connectingCotoId = Nothing
    }


closeSelectionColumnIfEmpty : Model -> Model
closeSelectionColumnIfEmpty model =
    if List.isEmpty model.context.selection then
        { model | cotoSelectionColumnOpen = False }
    else
        model
