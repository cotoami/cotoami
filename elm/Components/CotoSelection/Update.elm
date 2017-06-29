module Components.CotoSelection.Update exposing (..)

import App.Types exposing (Context, clearSelection, ViewInMobile(..))
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
            let
                ( newTimeline, newPost ) = 
                      postContent 
                          model.context.clientId 
                          model.context.cotonoma 
                          False 
                          model.cotoSelectionTitle 
                          model.timeline
            in
                { model 
                | timeline = newTimeline
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
            let
                timeline = model.timeline
                newModel = 
                    { model 
                    | timeline = { timeline | posts = setCotoSaved response timeline.posts }
                    }
                maybeStartCoto = 
                    case response.cotoId of
                        Nothing -> Nothing
                        Just cotoId -> getCoto cotoId newModel
                endCotos = getSelectedCoto newModel
            in
                case maybeStartCoto of
                    Nothing -> newModel ! []
                    Just startCoto ->
                        connect startCoto endCotos newModel ! []
          
        GroupingCotoPosted (Err _) ->
            model ! []


pinSelectedCotos : Model -> Model
pinSelectedCotos model =
    let
        cotos = model.context.selection |> List.filterMap (\cotoId -> getCoto cotoId model)
        graph = model.graph |> addRootConnections cotos
    in
        { model 
        | graph = graph
        , context = clearSelection model.context
        , viewInMobile = PinnedView
        }
    
