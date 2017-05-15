module Components.Connections.Update exposing (..)

import Dict
import App.Types exposing (CotoId)
import App.Graph exposing (Graph, Traversal)
import Components.Connections.Messages exposing (..)


type alias Model = ( Graph, Dict.Dict CotoId Traversal )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            model ! []
            
        CotoClick cotoId ->
            model ! []
            
        CotonomaClick key ->
            model ! []
            
        TraverseClick traverse ->
            model ! []
        
        OpenTraversal cotoId ->
            model ! []
