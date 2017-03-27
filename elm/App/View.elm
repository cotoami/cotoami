module App.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Exts.Maybe exposing (isNothing)
import App.Model exposing (..)
import App.Messages exposing (..)
import Components.AppHeader
import Components.Navigation
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
      div [ id "app" 
          , classList 
              [ ( "cotonomas-loading", model.cotonomasLoading )
              , ( "any-connections", False )
              ] 
          ]
          [ Components.AppHeader.view model
          , div [ id "app-body" ]
              [ div 
                  [ id "navigation" 
                  , classList 
                      [ ( "neverToggled", not model.navigationToggled )
                      , ( "empty", isNavigationEmpty model )
                      , ( "notEmpty", not (isNavigationEmpty model) )
                      , ( "animated", model.navigationToggled )
                      , ( "slideInDown", model.navigationToggled && model.navigationOpen )
                      , ( "slideOutUp", model.navigationToggled && not model.navigationOpen )
                      ]
                  ] (Components.Navigation.view model)
              , div [ id "flow" ]
                  [ Html.map TimelineMsg 
                      (Components.Timeline.View.view 
                          model.timeline 
                          model.session
                          model.cotonoma 
                          model.activeCotoId
                      )
                  ]
              , div 
                  [ id "stock"
                  , classList [ ( "hidden", True ) ]
                  ] 
                  [ div [] [ text "stock" ]
                  ]
              , div
                  [ id "open-flow", class "flow-stock-switch" ]
                  [ a [ class "tool-button", title "Show timeline" ] 
                      [ i [ class "material-icons" ] [ text "navigate_next" ] ] 
                  ]
              , div
                  [ id "open-stock", class "flow-stock-switch" ]
                  [ a [ class "tool-button", title "Show connections" ] 
                      [ i [ class "material-icons" ] [ text "navigate_before" ] ] 
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
