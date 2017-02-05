module Main exposing (..)

import Html exposing (program)
import App.Model exposing (..)
import App.Messages exposing (..)
import App.Update exposing (update)
import App.Commands exposing (fetchSession)
import App.View exposing (view)
import App.Subscriptions exposing (subscriptions)
import Components.Timeline.Commands exposing (fetchPosts)

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
    initModel ! 
        [ fetchSession
        , Cmd.map TimelineMsg fetchPosts 
        ]
