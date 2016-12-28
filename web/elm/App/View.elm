module App.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Exts.Maybe exposing (isNothing)
import App.Model exposing (..)
import App.Messages exposing (..)
import Components.AppHeader
import Components.Timeline
import Components.SigninModal


view : Model -> Html Msg
view model =
    let
        showAnonymousOption = (isNothing model.session) && not (List.isEmpty model.timeline.cotos)
    in
      div [ id "app" ]
          [ Components.AppHeader.view model
          , div [ id "app-body", class "container" ]
              [  Html.map TimelineMsg (Components.Timeline.view model.timeline model.session)
              ]
          , Html.map SigninModalMsg 
              (Components.SigninModal.view model.signinModal showAnonymousOption)
          ]
