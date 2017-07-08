module Components.CotoSelection.Update exposing (..)

import Set
import Task
import Process
import Time
import Maybe exposing (andThen, withDefault)
import App.Types exposing
    ( CotoId
    , Context
    , clearSelection
    , deleteSelection
    , setBeingDeselected
    , ViewInMobile(..)
    )
import App.Graph exposing (addConnections, addRootConnections)
import App.Model exposing (..)
import Components.CotoSelection.Messages exposing (..)
import Components.Timeline.Update exposing (postContent, setCotoSaved)
import Components.Timeline.Commands exposing (scrollToBottom, post)


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
            pinSelectedCotos model ! []

        ClearSelection ->
            { model
            | context = clearSelection model.context
            , connectMode = False
            , connectModalOpen = False
            , viewInMobile =
                case model.viewInMobile of
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
            , viewInMobile =
                if enabled then
                    case model.viewInMobile of
                        SelectionView -> TimelineView
                        anotherView -> anotherView
                else
                    model.viewInMobile
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
            | timeline = model.timeline
                |> \timeline -> { timeline | posts = setCotoSaved response timeline.posts }
            }
                |> (\model ->
                    response.cotoId
                        |> andThen (\cotoId -> getCoto cotoId model)
                        |> andThen (\groupingCoto ->
                            Just <| connect groupingCoto (getSelectedCoto model) model
                        )
                        |> \maybeModel -> withDefault model maybeModel ! []
                )

        GroupingCotoPosted (Err _) ->
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
            , viewInMobile = PinnedView
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
