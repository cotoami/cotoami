module Components.CotoSelection.Update exposing (..)

import Set
import Task
import Process
import Time
import Maybe exposing (andThen, withDefault)
import App.ActiveViewOnMobile exposing (ActiveViewOnMobile(..))
import App.Types.Context exposing (Context, clearSelection, deleteSelection, setBeingDeselected)
import App.Types.Graph exposing (addConnections, addRootConnections)
import App.Types.Post exposing (setCotoSaved)
import App.Types.Timeline exposing (postContent)
import App.Server.Coto exposing (post)
import App.Server.Graph exposing (pinCotos)
import App.Model exposing (..)
import Components.CotoSelection.Messages exposing (..)
import Components.Timeline.Commands exposing (scrollToBottom)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            model ! []

        DeselectingCoto cotoId ->
            { model | context = setBeingDeselected cotoId model.context } !
                [ Process.sleep (1 * Time.second)
                  |> Task.andThen (\_ -> Task.succeed ())
                  |> Task.perform (\_ -> DeselectCoto)
                ]

        DeselectCoto ->
            doDeselect model ! []

        ConfirmPin ->
            model ! []

        Pin ->
            pinSelectedCotos model !
                [ pinCotos
                    Pinned
                    (Maybe.map (\cotonoma -> cotonoma.key) model.context.cotonoma)
                    model.context.selection
                ]

        Pinned (Ok _) ->
            model ! []

        Pinned (Err _) ->
            model ! []

        ClearSelection ->
            { model
            | context = clearSelection model.context
            , connectMode = False
            , connectModalOpen = False
            , activeViewOnMobile =
                case model.activeViewOnMobile of
                    SelectionView -> TimelineView
                    anotherView -> anotherView
            } ! []

        CotonomaClick key ->
            model ! []

        OpenTraversal cotoId ->
            model ! []

        SetConnectMode enabled ->
            { model
            | connectMode = enabled
            , activeViewOnMobile =
                if enabled then
                    case model.activeViewOnMobile of
                        SelectionView -> TimelineView
                        anotherView -> anotherView
                else
                    model.activeViewOnMobile
            } ! []

        CotoSelectionTitleInput title ->
            { model | cotoSelectionTitle = title } ! []

        ConfirmCreateGroupingCoto ->
            model ! []

        PostGroupingCoto ->
            model.timeline
                |> postContent
                    model.context.clientId
                    model.context.cotonoma
                    False
                    model.cotoSelectionTitle
                |> \( timeline, newPost ) ->
                    { model
                    | timeline = timeline
                    , cotoSelectionTitle = ""
                    } !
                        [ scrollToBottom NoOp
                        , post
                            model.context.clientId
                            model.context.cotonoma
                            GroupingCotoPosted
                            newPost
                        ]

        GroupingCotoPosted (Ok response) ->
            { model
            | timeline =
                model.timeline
                    |> \timeline -> { timeline | posts = setCotoSaved response timeline.posts }
            }
                |> (\model ->
                    response.cotoId
                        |> andThen (\cotoId -> getCoto cotoId model)
                        |> andThen (\startCoto ->
                            let
                                endCotos = getSelectedCotos model
                            in
                                Just
                                    ( connect startCoto endCotos model
                                    , App.Server.Graph.connect
                                        Connected
                                        (Maybe.map (\cotonoma -> cotonoma.key) model.context.cotonoma)
                                        startCoto.id
                                        (List.map (\coto -> coto.id) endCotos)
                                    )
                        )
                        |> \maybeModelAndCmd -> withDefault (model ! []) maybeModelAndCmd
                )

        GroupingCotoPosted (Err _) ->
            model ! []

        Connected (Ok _) ->
            model ! []

        Connected (Err _) ->
            model ! []


pinSelectedCotos : Model -> Model
pinSelectedCotos model =
    model.context.selection
        |> List.filterMap (\cotoId -> getCoto cotoId model)
        |> \cotos -> model.graph |> addRootConnections cotos
        |> \graph ->
            { model
            | graph = graph
            , context = clearSelection model.context
            , activeViewOnMobile = PinnedView
            }


doDeselect : Model -> Model
doDeselect model =
    { model
    | context = model.context
        |> \context ->
            { context
            | selection =
                List.filter
                    (\id -> not(Set.member id context.deselecting))
                    context.selection
            , deselecting = Set.empty
            }
    }
