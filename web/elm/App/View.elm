module App.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Exts.Maybe exposing (isNothing)
import App.Model exposing (..)
import App.Messages exposing (..)
import Components.AppHeader
import Components.SigninModal
import Components.ProfileModal
import Components.Timeline


view : Model -> Html Msg
view model =
    let
        anyAnonymousCotos = (isNothing model.session) && not (List.isEmpty model.timeline.cotos)
    in
      div [ id "app" ]
          [ Components.AppHeader.view model
          , div [ id "app-body", class "container" ]
              [ Html.map TimelineMsg (Components.Timeline.view model.timeline model.session model.activeCotoId)
              ]
          , Html.map SigninModalMsg 
              (Components.SigninModal.view model.signinModal anyAnonymousCotos)
          , Html.map ProfileModalMsg 
              (Components.ProfileModal.view model.profileModal model.session)
          , a 
              [ class "info-button"
              , title "News and Feedback"
              , href "https://twitter.com/cotoami"
              , target "_blank"
              , hidden (model.timeline.editingNewCoto)  
              ] 
              [ i [ class "material-icons" ] [ text "info" ] ]
          ]
