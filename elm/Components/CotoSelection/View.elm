module Components.CotoSelection.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import App.Model exposing (..)
import App.Messages exposing (..)


cotoSelectionColumnDiv : Model -> Html Msg
cotoSelectionColumnDiv model =
    div [ id "coto-selection" ]
        [ div 
            [ class "column-header" ] 
            [ button 
                [ class "button" ] 
                [ i [ class "fa fa-thumb-tack", (attribute "aria-hidden" "true") ] []
                , text "Pin" 
                ]
            , button 
                [ class "button" ] 
                [ text "Connect" ]
            , span 
                [ class "group-title" ]
                [ input 
                    [ type_ "text"
                    , name "title"
                    , placeholder "Title for this group"
                    ] []
                , button 
                    [ class "button", disabled True ] 
                    [ text "Save" ]
                ]
            ]
        , div 
            [ class "column-body" ]
            []
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
