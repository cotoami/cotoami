module Components.Connections.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Components.Connections.Model exposing (..)
import Components.Connections.Messages exposing (..)


view : Model -> Html Msg
view model =
    div 
        [ id "connections" ] 
        [ text "connections"
        ]
