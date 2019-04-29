module Main exposing (Flags, init, main)

import App.Messages exposing (Msg(OnLocationChange))
import App.Model exposing (Model)
import App.Ports.LocalStorage
import App.Route exposing (Route(..), parseLocation)
import App.Server.Session exposing (fetchSession)
import App.Subscriptions exposing (subscriptions)
import App.Update exposing (update)
import App.View exposing (view)
import Navigation exposing (Location)


type alias Flags =
    { version : String
    , seed : Int
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
        flags.version
        flags.seed
        flags.lang
        (parseLocation location)
    , Cmd.batch
        [ App.Ports.LocalStorage.getAllItems ()
        , fetchSession
        ]
    )
