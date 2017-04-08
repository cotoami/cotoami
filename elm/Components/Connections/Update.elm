module Components.Connections.Update exposing (..)

import App.Graph exposing (Graph)
import Components.Connections.Messages exposing (..)


update : Msg -> Graph -> ( Graph, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            model ! []
            
        CotoClick cotoId ->
            model ! []
            
        CotonomaClick key ->
            model ! []
