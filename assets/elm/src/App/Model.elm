module App.Model exposing (..)

import Dict
import Set exposing (Set)
import Date
import Json.Encode exposing (Value)
import Json.Decode as Decode
import Exts.Maybe exposing (isNothing)
import List.Extra
import App.Route exposing (Route)
import App.ActiveViewOnMobile exposing (ActiveViewOnMobile(..))
import App.Types.Context exposing (..)
import App.Types.Coto exposing (Coto, CotoId, ElementId, Cotonoma, CotonomaKey)
import App.Types.Amishi exposing (Amishi, AmishiId, Presences)
import App.Types.Graph exposing (Direction(..), Graph, PinnedCotosView(..))
import App.Types.Timeline exposing (Timeline)
import App.Types.Traversal exposing (Traversals)
import App.Types.SearchResults exposing (SearchResults)
import App.Confirmation exposing (Confirmation)
import App.Modals exposing (Modal(..))
import App.Modals.SigninModal
import App.Modals.EditorModal
import App.Modals.InviteModal
import App.Modals.CotoMenuModal
import App.Modals.CotoModal
import App.Modals.ImportModal


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
    , searchInputFocus : Bool
    , editorModal : App.Modals.EditorModal.Model
    , cotoMenuModal : Maybe App.Modals.CotoMenuModal.Model
    , cotoModal : Maybe App.Modals.CotoModal.Model
    , signinModal : App.Modals.SigninModal.Model
    , inviteModal : App.Modals.InviteModal.Model
    , recentCotonomas : List Cotonoma
    , cotonomasLoading : Bool
    , subCotonomas : List Cotonoma
    , timeline : Timeline
    , searchResults : SearchResults
    , cotoSelectionColumnOpen : Bool
    , cotoSelectionTitle : String
    , connectingTarget : Maybe ConnectingTarget
    , connectingDirection : Direction
    , graph : Graph
    , loadingGraph : Bool
    , traversals : Traversals
    , importModal : App.Modals.ImportModal.Model
    , pinnedCotosView : PinnedCotosView
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
    , confirmation = App.Confirmation.defaultConfirmation
    , searchInputFocus = False
    , editorModal = App.Modals.EditorModal.defaultModel
    , cotoMenuModal = Nothing
    , cotoModal = Nothing
    , signinModal = App.Modals.SigninModal.initModel False
    , inviteModal = App.Modals.InviteModal.defaultModel
    , recentCotonomas = []
    , cotonomasLoading = False
    , subCotonomas = []
    , timeline = App.Types.Timeline.defaultTimeline
    , searchResults = App.Types.SearchResults.defaultSearchResults
    , cotoSelectionColumnOpen = False
    , cotoSelectionTitle = ""
    , connectingTarget = Nothing
    , connectingDirection = App.Types.Graph.Outbound
    , graph = App.Types.Graph.defaultGraph
    , loadingGraph = False
    , traversals = App.Types.Traversal.defaultTraversals
    , importModal = App.Modals.ImportModal.defaultModel
    , pinnedCotosView = DocumentView
    }


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


getCoto : CotoId -> Model -> Maybe Coto
getCoto cotoId model =
    Exts.Maybe.oneOf
        [ Dict.get cotoId model.graph.cotos
        , App.Types.Timeline.getCoto cotoId model.timeline
        , App.Types.SearchResults.getCoto cotoId model.searchResults
        , getCotoFromCotonomaList cotoId model.recentCotonomas
        , getCotoFromCotonomaList cotoId model.subCotonomas
        , model.context.cotonoma
            |> Maybe.map
                (\cotonoma ->
                    if cotonoma.cotoId == cotoId then
                        Just (App.Types.Coto.toCoto cotonoma)
                    else
                        Nothing
                )
            |> Maybe.withDefault Nothing
        ]


getCotoIdsToWatch : Model -> Set CotoId
getCotoIdsToWatch model =
    model.timeline.posts
        |> List.filterMap (\post -> post.cotoId)
        |> List.append (Dict.keys model.graph.cotos)
        |> List.append
            (model.context.cotonoma
                |> Maybe.map (\cotonoma -> [ cotonoma.cotoId ])
                |> Maybe.withDefault []
            )
        |> Set.fromList


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


cotonomatize : Cotonoma -> CotoId -> Model -> Model
cotonomatize cotonoma cotoId model =
    { model
        | timeline = App.Types.Timeline.cotonomatize cotonoma cotoId model.timeline
        , graph = App.Types.Graph.cotonomatize cotonoma cotoId model.graph
    }


getSelectedCotos : Model -> List Coto
getSelectedCotos model =
    model.context.selection
        |> List.filterMap (\cotoId -> getCoto cotoId model)
        |> List.reverse


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


openCotoMenuModal : Coto -> Model -> Model
openCotoMenuModal coto model =
    coto
        |> App.Modals.CotoMenuModal.initModel
        |> (\modal -> { model | cotoMenuModal = Just modal })
        |> App.Modals.openModal CotoMenuModal


openCoto : Coto -> Model -> Model
openCoto coto model =
    coto
        |> App.Modals.CotoModal.initModel
        |> (\modal -> { model | cotoModal = Just modal })
        |> App.Modals.openModal CotoModal


confirmPostAndConnect : Maybe String -> String -> Model -> Model
confirmPostAndConnect summary content model =
    { model
        | connectingTarget = Just (NewPost content summary)
        , connectingDirection = Inbound
    }
        |> \model -> App.Modals.openModal ConnectModal model


isNavigationEmpty : Model -> Bool
isNavigationEmpty model =
    (isNothing model.context.cotonoma)
        && (List.isEmpty model.recentCotonomas)
        && (List.isEmpty model.subCotonomas)


isStockEmpty : Model -> Bool
isStockEmpty model =
    List.isEmpty model.graph.rootConnections


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
                App.Types.Graph.batchConnect session.id direction cotos target model.graph
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


areTimelineAndGraphLoaded : Model -> Bool
areTimelineAndGraphLoaded model =
    (not model.timeline.loading) && (not model.loadingGraph)


isTimelineReady : Model -> Bool
isTimelineReady model =
    (areTimelineAndGraphLoaded model)
        && (not model.timeline.initializingScrollPos)


deleteCoto : Coto -> Model -> Model
deleteCoto coto model =
    { model
        | timeline = App.Types.Timeline.deleteCoto coto model.timeline
        , graph = App.Types.Graph.removeCoto coto.id model.graph
        , traversals = App.Types.Traversal.closeTraversal coto.id model.traversals
        , context = deleteSelection coto.id model.context
    }
