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
import Components.CotonomaModal.View


view : Model -> Html Msg
view model =
    let
        anyAnonymousCotos = (isNothing model.session) && not (List.isEmpty model.timeline.posts)
    in
      div [ id "app" ]
          [ Components.AppHeader.view model
          , div [ id "app-body", class "container" ]
              [ div [ id "flow" ]
                  [ Html.map TimelineMsg 
                      (Components.Timeline.View.view 
                          model.timeline 
                          model.session 
                          model.cotonoma 
                          model.activeCotoId
                      )
                  ]
              , div [ id "stock" ]
                  [ div [ id "cotonomas" ]
                      [ div [ class "coto-as-cotonoma" ]
                          [ a []
                              [ i [ class "material-icons" ] [ text "exit_to_app" ]
                              , span [ class "cotonoma-name" ] [ text "Kubernetes" ]
                              ]
                          ]
                      , div [ class "coto-as-cotonoma" ]
                          [ a []
                              [ i [ class "material-icons" ] [ text "exit_to_app" ]
                              , span [ class "cotonoma-name" ] [ text "Elixir" ]
                              ]
                          ]
                      , div [ class "coto-as-cotonoma" ]
                          [ a []
                              [ i [ class "material-icons" ] [ text "exit_to_app" ]
                              , span [ class "cotonoma-name" ] [ text "Groovy" ]
                              ]
                          ]
                      , div [ class "coto-as-cotonoma" ]
                          [ a []
                              [ i [ class "material-icons" ] [ text "exit_to_app" ]
                              , span [ class "cotonoma-name" ] [ text "Elm" ]
                              ]
                          ]
                      , div [ class "coto-as-cotonoma" ]
                          [ a []
                              [ i [ class "material-icons" ] [ text "exit_to_app" ]
                              , span [ class "cotonoma-name" ] [ text "CSS" ]
                              ]
                          ]
                      , div [ class "coto-as-cotonoma" ]
                          [ a []
                              [ i [ class "material-icons" ] [ text "exit_to_app" ]
                              , span [ class "cotonoma-name" ] [ text "Scala" ]
                              ]
                          ]
                      , div [ class "coto-as-cotonoma" ]
                          [ a []
                              [ i [ class "material-icons" ] [ text "exit_to_app" ]
                              , span [ class "cotonoma-name" ] [ text "Docker" ]
                              ]
                          ]
                      ]
                  ]
              ]
          , Html.map ConfirmModalMsg 
              (Components.ConfirmModal.View.view model.confirmModal)
          , Html.map SigninModalMsg 
              (Components.SigninModal.view model.signinModal anyAnonymousCotos)
          , Html.map ProfileModalMsg 
              (Components.ProfileModal.view model.session model.profileModal)
          , Html.map CotoModalMsg 
              (Components.CotoModal.view model.cotoModal)
          , Html.map CotonomaModalMsg 
              (Components.CotonomaModal.View.view model.session model.cotonomaModal)
          , a 
              [ class "info-button"
              , title "News and Feedback"
              , href "https://twitter.com/cotoami"
              , target "_blank"
              , hidden (model.timeline.editingNew)  
              ] 
              [ i [ class "material-icons" ] [ text "info" ] ]
          ]
