module Main exposing (..)

import Html exposing (program)
import App.Model exposing (..)
import App.Messages exposing (..)
import App.Update exposing (update)
import App.Commands exposing (fetchSession, fetchCotos)
import App.View exposing (view)
import App.Subscriptions exposing (subscriptions)

main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : ( Model, Cmd Msg )
init =
    initModel ! [ fetchSession, fetchCotos ]
