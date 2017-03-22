module Components.Navigation exposing (..)

import Html exposing (..)
import App.Model exposing (Model)
import App.Messages exposing (Msg)
import Components.Cotonomas


view : Model -> List (Html Msg)
view model =
    [ Components.Cotonomas.view model.cotonomas ]
