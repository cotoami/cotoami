module Main exposing (..)

import Navigation exposing (Location)
import App.Routing exposing (parseLocation)
import App.Model exposing (..)
import App.Messages exposing (..)
import App.Update exposing (update, loadHome, loadCotonoma)
import App.Commands exposing (fetchSession, fetchCotonomas)
import App.View exposing (view)
import App.Subscriptions exposing (subscriptions)

main : Program Never Model Msg
main =
    Navigation.program OnLocationChange
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : Location -> ( Model, Cmd Msg )
init location =
    let
        route = parseLocation location
        initialModel = initModel route
        ( model, cmd ) =
            case route of
                CotonomaRoute key -> loadCotonoma key initialModel
                _ -> loadHome initialModel
    in
        model ! [fetchSession, cmd]
