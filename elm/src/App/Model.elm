module App.Model exposing (..)

import Dict
import Date
import Exts.Maybe exposing (isNothing)
import List.Extra
import App.Route exposing (Route)
import App.ActiveViewOnMobile exposing (ActiveViewOnMobile(..))
import App.Types.Context exposing (..)
import App.Types.Coto exposing (Coto, CotoId, ElementId, Cotonoma, CotonomaKey)
import App.Types.Amishi exposing (Amishi, AmishiId, Presences)
import App.Types.Graph exposing (Direction(..), Graph, defaultGraph, batchConnect)
import App.Types.Timeline exposing (Timeline, defaultTimeline)
import App.Types.Traversal exposing (Traversals, defaultTraversals)
import App.Confirmation exposing (Confirmation, defaultConfirmation)
import App.Modals.SigninModal
import App.Modals.EditorModal
import App.Modals.InviteModal
import App.Modals.CotoMenuModal
import App.Modals.CotoModal
import App.Modals.ImportModal


type Modal
    = ConfirmModal
    | SigninModal
    | EditorModal
    | ProfileModal
    | InviteModal
    | CotoMenuModal
    | CotoModal
    | ConnectModal
    | ImportModal


type ConnectingTarget
    = Coto Coto
    | NewPost String (Maybe String)


type alias Model =
    { route : Route
    , context : Context
    , activeViewOnMobile : ActiveViewOnMobile
    , navigationToggled : Bool
    , navigationOpen : Bool
    , presences : Presences
    , modals : List Modal
    , confirmation : Confirmation
    , editorModal : App.Modals.EditorModal.Model
    , cotoMenuModal : Maybe App.Modals.CotoMenuModal.Model
    , cotoModal : Maybe App.Modals.CotoModal.Model
    , signinModal : App.Modals.SigninModal.Model
    , inviteModal : App.Modals.InviteModal.Model
    , pinnedCotonomas : List Cotonoma
    , recentCotonomas : List Cotonoma
    , cotonomasLoading : Bool
    , subCotonomas : List Cotonoma
    , timeline : Timeline
    , cotoSelectionColumnOpen : Bool
    , cotoSelectionTitle : String
    , connectingTarget : Maybe ConnectingTarget
    , connectingDirection : Direction
    , graph : Graph
    , traversals : Traversals
    , importModal : App.Modals.ImportModal.Model
    }


initModel : Int -> Route -> Model
initModel seed route =
    { route = route
    , context = initContext seed
    , activeViewOnMobile = TimelineView
    , navigationToggled = False
    , navigationOpen = False
    , presences = Dict.empty
    , modals = []
    , confirmation = defaultConfirmation
    , editorModal = App.Modals.EditorModal.defaultModel
    , cotoMenuModal = Nothing
    , cotoModal = Nothing
    , signinModal = App.Modals.SigninModal.defaultModel
    , inviteModal = App.Modals.InviteModal.defaultModel
    , pinnedCotonomas = []
    , recentCotonomas = []
    , cotonomasLoading = False
    , subCotonomas = []
    , timeline = defaultTimeline
    , cotoSelectionColumnOpen = False
    , cotoSelectionTitle = ""
    , connectingTarget = Nothing
    , connectingDirection = App.Types.Graph.Outbound
    , graph = defaultGraph
    , traversals = defaultTraversals
    , importModal = App.Modals.ImportModal.defaultModel
    }


getCoto : CotoId -> Model -> Maybe Coto
getCoto cotoId model =
    Exts.Maybe.oneOf
        [ Dict.get cotoId model.graph.cotos
        , App.Types.Timeline.getCoto cotoId model.timeline
        , getCotoFromCotonomaList cotoId model.pinnedCotonomas
        , getCotoFromCotonomaList cotoId model.recentCotonomas
        , getCotoFromCotonomaList cotoId model.subCotonomas
        ]


getCotoFromCotonomaList : CotoId -> List Cotonoma -> Maybe Coto
getCotoFromCotonomaList cotoId cotonomas =
    cotonomas
        |> List.filter (\cotonoma -> cotonoma.cotoId == cotoId)
        |> List.head
        |> Maybe.map App.Types.Coto.toCoto


updateCotoContent : Coto -> Model -> Model
updateCotoContent coto model =
    { model
        | timeline = App.Types.Timeline.updateContent coto model.timeline
        , graph = App.Types.Graph.updateContent coto model.graph
    }


cotonomatize : CotoId -> Maybe CotonomaKey -> Model -> Model
cotonomatize cotoId maybeCotonomaKey model =
    maybeCotonomaKey
        |> Maybe.map
            (\key ->
                { model
                    | timeline = App.Types.Timeline.cotonomatize cotoId key model.timeline
                    , graph = App.Types.Graph.cotonomatize cotoId key model.graph
                }
            )
        |> Maybe.withDefault model


getSelectedCotos : Model -> List Coto
getSelectedCotos model =
    List.filterMap
        (\cotoId -> getCoto cotoId model)
        model.context.selection


updateRecentCotonomas : Cotonoma -> Model -> Model
updateRecentCotonomas cotonoma model =
    model.recentCotonomas
        |> (::) cotonoma
        |> List.Extra.uniqueBy (\c -> c.id)
        |> List.sortBy (\c -> Date.toTime c.updatedAt)
        |> List.reverse
        |> (\cotonomas -> { model | recentCotonomas = cotonomas })


updateRecentCotonomasByCoto : { r | postedIn : Maybe Cotonoma } -> Model -> Model
updateRecentCotonomasByCoto post model =
    post.postedIn
        |> Maybe.map (\cotonoma -> updateRecentCotonomas cotonoma model)
        |> Maybe.withDefault model


openModal : Modal -> Model -> Model
openModal modal model =
    if List.member modal model.modals then
        model
    else
        { model | modals = modal :: model.modals }


closeActiveModal : Model -> Model
closeActiveModal model =
    { model | modals = Maybe.withDefault [] (List.tail model.modals) }


closeModal : Modal -> Model -> Model
closeModal modal model =
    { model | modals = List.filter (\m -> m /= modal) model.modals }


clearModals : Model -> Model
clearModals model =
    { model | modals = [] }


confirm : Confirmation -> Model -> Model
confirm confirmation model =
    { model | confirmation = confirmation }
        |> openModal ConfirmModal


maybeConfirm : Maybe Confirmation -> Model -> Model
maybeConfirm maybeConfirmation model =
    maybeConfirmation
        |> Maybe.map (\confirmation -> confirm confirmation model)
        |> Maybe.withDefault model


openCotoMenuModal : Coto -> Model -> Model
openCotoMenuModal coto model =
    coto
        |> App.Modals.CotoMenuModal.initModel (isCotonomaAndPinned coto model)
        |> Just
        |> (\modal -> { model | cotoMenuModal = modal })
        |> openModal CotoMenuModal


openCoto : Coto -> Model -> Model
openCoto coto model =
    coto
        |> App.Modals.CotoModal.initModel
        |> Just
        |> (\modal -> { model | cotoModal = modal })
        |> openModal CotoModal


confirmPostAndConnect : Maybe String -> String -> Model -> Model
confirmPostAndConnect summary content model =
    { model
        | connectingTarget = Just (NewPost content summary)
        , connectingDirection = Inbound
    }
        |> \model -> openModal ConnectModal model


isNavigationEmpty : Model -> Bool
isNavigationEmpty model =
    (isNothing model.context.cotonoma)
        && (List.isEmpty model.recentCotonomas)
        && (List.isEmpty model.subCotonomas)


isStockEmpty : Model -> Bool
isStockEmpty model =
    List.isEmpty model.graph.rootConnections


isCotonomaAndPinned : Coto -> Model -> Bool
isCotonomaAndPinned coto model =
    coto.cotonomaKey
        |> Maybe.map
            (\key -> List.any (\c -> c.key == key) model.pinnedCotonomas)
        |> Maybe.withDefault False


openTraversal : CotoId -> Model -> Model
openTraversal cotoId model =
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
            App.Types.Traversal.openTraversal cotoId model.traversals
        , activeViewOnMobile = TraversalsView
    }


connect : Direction -> List Coto -> Coto -> Model -> Model
connect direction cotos target model =
    model.context.session
        |> Maybe.map
            (\session ->
                batchConnect session direction cotos target model.graph
                    |> (\graph ->
                            { model
                                | graph = graph
                                , connectingTarget = Nothing
                            }
                       )
            )
        |> Maybe.withDefault model


closeSelectionColumnIfEmpty : Model -> Model
closeSelectionColumnIfEmpty model =
    if List.isEmpty model.context.selection then
        { model | cotoSelectionColumnOpen = False }
    else
        model


clickCoto : ElementId -> CotoId -> Model -> Model
clickCoto elementId cotoId model =
    model.context
        |> setElementFocus (Just elementId)
        |> setCotoFocus (Just cotoId)
        |> \context -> { model | context = context }
