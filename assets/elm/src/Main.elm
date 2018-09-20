module Main exposing (..)

import Navigation exposing (Location)
import App.Route exposing (parseLocation, Route(..))
import App.Model exposing (Model)
import App.Messages exposing (Msg(OnLocationChange))
import App.Update exposing (update)
import App.Server.Session exposing (fetchSession)
import App.View exposing (view)
import App.Subscriptions exposing (subscriptions)
import App.Ports.LocalStorage


type alias Flags =
    { seed : Int
    , lang : String
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
    ( App.Model.initModel
        flags.seed
        flags.lang
        (parseLocation location)
    , Cmd.batch
        [ App.Ports.LocalStorage.getAllItems ()
        , fetchSession
        ]
    )
