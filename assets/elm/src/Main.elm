module Main exposing (..)

import Navigation exposing (Location)
import App.Route exposing (parseLocation, Route(..))
import App.Model exposing (..)
import App.Messages exposing (..)
import App.Update exposing (update)
import App.Server.Session exposing (fetchSession)
import App.View exposing (view)
import App.Subscriptions exposing (subscriptions)
import App.Ports.LocalStorage


type alias Flags =
    { seed : Int
    }


main : Program Flags Model Msg
main =
    Navigation.programWithFlags OnLocationChange
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : Flags -> Location -> ( Model, Cmd Msg )
init flags location =
    let
        route =
            parseLocation location
    in
        ( initModel flags.seed route
        , Cmd.batch
            [ App.Ports.LocalStorage.getAllItems ()
            , fetchSession
            ]
        )
