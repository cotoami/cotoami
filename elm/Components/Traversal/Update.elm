module Components.Traversal.Update exposing (..)

import Dict
import App.Types exposing (CotoId)
import App.Graph exposing (Graph, Traversal, doTraverse)
import Components.Traversal.Messages exposing (..)


type alias Model = ( Graph, Dict.Dict CotoId Traversal )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg ( graph, traversals ) =
    case msg of
        NoOp ->
            ( graph, traversals ) ! []
            
        CotoClick cotoId ->
            ( graph, traversals ) ! []
            
        CotonomaClick key ->
            ( graph, traversals ) ! []
            
        TraverseClick traverse ->
            ( graph
            , Dict.insert 
                traverse.traversal.start 
                (doTraverse traverse) 
                traversals 
            ) ! []
        
        OpenTraversal cotoId ->
            ( graph, traversals ) ! []
