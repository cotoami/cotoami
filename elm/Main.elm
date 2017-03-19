module Main exposing (..)

import Navigation exposing (Location)
import App.Routing exposing (parseLocation)
import App.Model exposing (..)
import App.Messages exposing (..)
import App.Update exposing (update, loadHome, loadCotonoma)
import App.Commands exposing (fetchSession, fetchCotonomas)
import App.View exposing (view)
import App.Subscriptions exposing (subscriptions)


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
        route = parseLocation location
        initialModel = initModel flags.seed route
        ( model, cmd ) =
            case route of
                CotonomaRoute key -> loadCotonoma key initialModel
                _ -> loadHome initialModel
    in
        model ! [fetchSession, cmd]
