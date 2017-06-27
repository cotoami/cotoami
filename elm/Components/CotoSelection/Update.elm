module Components.CotoSelection.Update exposing (..)

import App.Types exposing (Context, clearSelection)
import App.Graph exposing (addConnections, addRootConnections)
import App.Model exposing (..)
import Components.CotoSelection.Messages exposing (..)
import Components.Timeline.Update exposing (postContent)
import Components.Timeline.Commands exposing (scrollToBottom)


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
            } ! []
            
        OpenCoto coto ->
            model ! []
            
        CotonomaClick key ->
            model ! []
            
        OpenTraversal cotoId ->
            model ! []
            
        SetConnectMode enabled ->
            { model | connectMode = enabled } ! []
                
        CotoSelectionTitleInput title ->
            { model | cotoSelectionTitle = title } ! []
            
        ConfirmCreateGroupingCoto ->
            model ! []
                
        CreateGroupingCoto ->
            let
                ( newTimeline, _ ) = 
                      postContent 
                          model.context.clientId 
                          model.context.cotonoma 
                          False 
                          model.cotoSelectionTitle 
                          model.timeline
            in
                { model | timeline = newTimeline } ! 
                    [ scrollToBottom NoOp
                    ]


pinSelectedCotos : Model -> Model
pinSelectedCotos model =
    let
        cotos = model.context.selection |> List.filterMap (\cotoId -> getCoto cotoId model)
        graph = model.graph |> addRootConnections cotos
    in
        { model 
        | graph = graph
        , context = clearSelection model.context
        }
    
