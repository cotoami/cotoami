module Components.Connections.Update exposing (..)

import Components.Connections.Model exposing (..)
import Components.Connections.Messages exposing (..)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            model ! []
            
        CotoClick cotoId ->
            model ! []
