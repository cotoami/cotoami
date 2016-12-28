module App.Subscriptions exposing (..)

import Keyboard exposing (..)
import App.Model exposing (Model)
import App.Messages exposing (..)


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Keyboard.downs KeyDown
        , Keyboard.ups KeyUp
        ]
