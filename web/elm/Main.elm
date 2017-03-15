module Main exposing (..)

import Navigation exposing (Location)
import App.Routing exposing (parseLocation)
import App.Model exposing (..)
import App.Messages exposing (..)
import App.Update exposing (update)
import App.Commands exposing (fetchSession, fetchCotonomas)
import App.View exposing (view)
import App.Subscriptions exposing (subscriptions)
import Components.Timeline.Commands exposing (fetchPosts)

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
    initModel (parseLocation location) ! 
        [ fetchSession
        , fetchCotonomas Nothing
        , Cmd.map TimelineMsg fetchPosts 
        ]
