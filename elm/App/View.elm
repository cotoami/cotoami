module App.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
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
import Components.Connections.View
import Components.ConnectModal


view : Model -> Html Msg
view model =
    let
        anyAnonymousCotos = (isNothing model.session) && not (List.isEmpty model.timeline.posts)
    in
      div [ id "app" 
          , classList 
              [ ( "cotonomas-loading", model.cotonomasLoading )
              , ( "stock-is-not-empty", not (isStockEmpty model) )
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
                          model.cotoSelection
                          model.cotonoma
                          model.session
                          model.timeline 
                      )
                  ]
              , div 
                  [ id "stock"
                  , classList 
                      [ ( "neverToggled", not model.stockToggled )
                      , ( "empty", isStockEmpty model )
                      , ( "notEmpty", not (isStockEmpty model) )
                      , ( "animated", model.stockToggled )
                      , ( "slideInRight", model.stockToggled && model.stockOpen )
                      , ( "slideOutRight", model.stockToggled && not model.stockOpen )
                      ]
                  ] 
                  [ Html.map ConnectionsMsg 
                      (Components.Connections.View.view 
                          model.cotoSelection 
                          model.connections
                      )
                  ]
              , flowStockSwitch model
              ]
          , cotoSelectionTools model
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
          , Components.ConnectModal.view model
          , a 
              [ class "tool-button info-button"
              , title "News and Feedback"
              , href "https://twitter.com/cotoami"
              , target "_blank"
              , hidden (model.timeline.editingNew)  
              ] 
              [ i [ class "material-icons" ] [ text "info" ] ]
          ]


cotoSelectionTools : Model -> Html Msg
cotoSelectionTools model =
    if List.isEmpty model.cotoSelection then
        div [] []
    else
        div [ id "coto-selection-tools" ] 
            [ if model.connectMode then
                div [ class "connect-mode" ]
                    [ span 
                        [ class "connect-mode-message" ] 
                        [ text "Select a target coto..." ]
                    , button 
                        [ class "button", onClick (SetConnectMode False) ] 
                        [ text "Cancel" ]
                    ]
              else
                div [ class "default" ]
                    [ div [ class "selection-info" ]
                        [ span 
                            [ class "selection-count" ] 
                            [ text (model.cotoSelection |> List.length |> toString) ]
                        , text " cotos"
                        ]
                    , div [ class "buttons" ]
                        [ button 
                           [ class "button", onClick (SetConnectMode True) ] 
                           [ text "Connect" ]
                        , button 
                           [ class "button", onClick Stock ] 
                           [ text "Stock" ]
                        , button 
                           [ class "button", onClick ClearSelection ] 
                           [ text "Clear" ]
                        ]
                    ]
            ]


flowStockSwitch : Model -> Html Msg
flowStockSwitch model =
    if isStockEmpty model then
        div [] []
    else
        let
            ( divId, linkTitle, iconName ) =
                if model.stockOpen then
                    ( "open-flow", "Show timeline", "navigate_next" )
                else
                    ( "open-stock", "Show connections", "navigate_before" )
        in
            div
                [ id divId, class "flow-stock-switch" ]
                [ a 
                    [ class "tool-button"
                    , title linkTitle
                    , onClick StockToggle 
                    ] 
                    [ i [ class "material-icons" ] [ text iconName ] ] 
                ]
