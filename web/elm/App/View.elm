module App.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Exts.Maybe exposing (isNothing)
import App.Model exposing (..)
import App.Messages exposing (..)
import Components.AppHeader
import Components.ConfirmModal.View
import Components.SigninModal
import Components.ProfileModal
import Components.CotoModal
import Components.Timeline.View
import Components.CotonomaModal


view : Model -> Html Msg
view model =
    let
        anyAnonymousCotos = (isNothing model.session) && not (List.isEmpty model.timeline.cotos)
    in
      div [ id "app" ]
          [ Components.AppHeader.view model
          , div [ id "app-body", class "container" ]
              [ Html.map TimelineMsg 
                  (Components.Timeline.View.view 
                      model.timeline 
                      model.session 
                      model.cotonoma 
                      model.activeCotoId
                  )
              ]
          , Html.map ConfirmModalMsg 
              (Components.ConfirmModal.View.view model.confirmModal)
          , Html.map SigninModalMsg 
              (Components.SigninModal.view model.signinModal anyAnonymousCotos)
          , Html.map ProfileModalMsg 
              (Components.ProfileModal.view model.profileModal model.session)
          , Html.map CotoModalMsg 
              (Components.CotoModal.view model.cotoModal)
          , Html.map CotonomaModalMsg 
              (Components.CotonomaModal.view model.cotonomaModal)
          , a 
              [ class "info-button"
              , title "News and Feedback"
              , href "https://twitter.com/cotoami"
              , target "_blank"
              , hidden (model.timeline.editingNewCoto)  
              ] 
              [ i [ class "material-icons" ] [ text "info" ] ]
          ]
