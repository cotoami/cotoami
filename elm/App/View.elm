module App.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Exts.Maybe exposing (isNothing)
import App.Types exposing (ViewInMobile(..))
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
import Components.Pinned.View
import Components.ConnectModal
import Components.Traversals.Model
import Components.Traversals.View


view : Model -> Html Msg
view model =
    let
        anyAnonymousCotos = (isNothing model.session) && not (List.isEmpty model.timeline.posts)
    in
      div [ id "app" 
          , classList 
              [ ( "cotonomas-loading", model.cotonomasLoading )
              , ( "navigation-is-not-empty", not (isNavigationEmpty model) )
              , ( "stock-is-not-empty", not (isStockEmpty model) )
              ] 
          ]
          [ Components.AppHeader.view model
          , div [ id "app-body" ]
              (List.concat
                  [ defaultColumnDivs model
                  , List.map
                      (\div -> Html.map TraversalMsg div)
                      (Components.Traversals.View.view
                          model.cotoSelection 
                          model.cotonoma 
                          model.graph 
                          model.traversals
                      )
                  , [ viewSwitchContainerDiv model ]
                  ]
              )
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


defaultColumnDivs : Model -> List (Html Msg)
defaultColumnDivs model =
    [ div 
        [ id "main-nav" 
        , classList 
            [ ( "neverToggled", not model.navigationToggled )
            , ( "empty", isNavigationEmpty model )
            , ( "notEmpty", not (isNavigationEmpty model) )
            , ( "animated", model.navigationToggled )
            , ( "slideInDown", model.navigationToggled && model.navigationOpen )
            , ( "slideOutUp", model.navigationToggled && not model.navigationOpen )
            ]
        ] (Components.Navigation.view model)
    , div [ id "main-timeline" ]
        [ Html.map TimelineMsg 
            (Components.Timeline.View.view 
                model.cotoSelection
                model.cotonoma
                model.session
                model.graph
                model.timeline 
            )
        ]
    , div 
        [ id "main-stock"
        , classList 
            [ ( "neverToggled", not model.stockToggled )
            , ( "empty", isStockEmpty model )
            , ( "notEmpty", not (isStockEmpty model) )
            , ( "animated", model.stockToggled )
            , ( "fadeIn", model.stockToggled && model.stockOpen )
            , ( "fadeOut", model.stockToggled && not model.stockOpen )
            ]
        ] 
        [ Components.Pinned.View.view 
            model.cotoSelection
            model.cotonoma
            model.graph
        ]
    ]
    

cotoSelectionTools : Model -> Html Msg
cotoSelectionTools model =
    if List.isEmpty model.cotoSelection then
        div [] []
    else
        div [ id "coto-selection-tools" ] 
            [ a [ class "close", onClick ClearSelection ] 
                [ i [ class "fa fa-times", (attribute "aria-hidden" "true") ] [] ] 
            , if model.connectMode then
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
                        , text " cotos selected"
                        ]
                    , div [ class "buttons" ]
                        [ button 
                           [ class "button", onClick Pin ] 
                           [ i [ class "fa fa-thumb-tack", (attribute "aria-hidden" "true") ] []
                           , text "Pin" 
                           ]
                        , button 
                           [ class "button", onClick (SetConnectMode True) ] 
                           [ text "Connect" ]
                        ]
                    ]
            ]
            
            
viewSwitchContainerDiv : Model -> Html Msg
viewSwitchContainerDiv model =
    div
        [ id "view-switch-container" ]
        [ viewSwitchDiv 
            "switch-to-timeline" 
            "fa-comments" 
            "Switch to timeline" 
            (model.viewInMobile == TimelineView) 
            False
        , viewSwitchDiv 
            "switch-to-pinned" 
            "fa-thumb-tack" 
            "Switch to pinned cotos" 
            (model.viewInMobile == PinnedView) 
            (isStockEmpty model)
        , viewSwitchDiv 
            "switch-to-traversals" 
            "fa-share-alt" 
            "Switch to traversals" 
            (model.viewInMobile == TraversalsView) 
            (Components.Traversals.Model.isEmpty model.traversals)
        ]
    
    
viewSwitchDiv : String -> String -> String -> Bool -> Bool -> Html Msg
viewSwitchDiv divId iconName buttonTitle selected empty =
    div
        [ id divId
        ,  classList 
            [ ( "view-switch", True )
            , ( "selected", selected )
            , ( "empty", empty )
            ]
        ]
        [ a 
            [ class "tool-button"
            , title buttonTitle
            ] 
            [ i [ class ("fa " ++ iconName), (attribute "aria-hidden" "true") ] [] ] 
        ]
        

flowStockSwitch : Model -> Html Msg
flowStockSwitch model =
    if isStockEmpty model then
        div [] []
    else
        let
            ( divId, linkTitle, icon ) =
                if model.stockOpen then
                    ( "open-flow"
                    , "Show timeline"
                    , i [ class "fa fa-comments", (attribute "aria-hidden" "true") ] []
                    )
                else
                    ( "open-stock"
                    , "Show connections"
                    , i [ class "fa fa-thumb-tack", (attribute "aria-hidden" "true") ] []
                    )
        in
            div
                [ id divId, class "flow-stock-switch" ]
                [ a 
                    [ class "tool-button"
                    , title linkTitle
                    , onClick StockToggle 
                    ] 
                    [ icon ] 
                ]
