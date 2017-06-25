module Components.CotoSelection.View exposing (..)

import Html exposing (..)
import Html.Keyed
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import App.Types exposing (Coto, CotoId, Cotonoma, CotoSelection)
import App.Graph exposing (..)
import App.Model exposing (..)
import App.Messages exposing (..)
import App.Markdown
import Components.Coto


cotoSelectionColumnDiv : Model -> Html Msg
cotoSelectionColumnDiv model =
    div [ id "coto-selection" ]
        [ div 
            [ class "column-header" ] 
            [ selectionInfoDiv model
            , cotoSelectionToolsDiv
            ]
        , div 
            [ class "column-body" ]
            [ selectedCotosDiv model ]
        ]


selectionInfoDiv : Model -> Html Msg
selectionInfoDiv model =
    div [ class "selection-info" ]
        [ span 
            [ class "selection-count" ] 
            [ text (model.cotoSelection |> List.length |> toString) ]
        , text " cotos selected"
        ]
        
  
cotoSelectionToolsDiv : Html Msg
cotoSelectionToolsDiv =
    div [ class "selection-tools" ]
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


selectedCotosDiv : Model -> Html Msg
selectedCotosDiv model =
    Html.Keyed.node
        "div"
        [ id "selected-cotos" ]
        (List.filterMap 
            (\cotoId -> 
                case getCoto cotoId model of
                    Nothing -> Nothing
                    Just coto -> Just 
                        ( toString cotoId
                        , cotoDiv model.cotonoma model.graph coto
                        )
            ) 
            (List.reverse model.cotoSelection)
        )


cotoDiv : Maybe Cotonoma -> Graph -> Coto -> Html Msg
cotoDiv maybeCotonoma graph coto =
    div 
        [ class "coto" ]
        [ div 
            [ class "coto-inner" ]
            [ Components.Coto.headerDiv CotonomaClick maybeCotonoma graph coto
            , bodyDiv graph coto
            , Components.Coto.openTraversalButtonDiv OpenTraversal (Just coto.id) graph 
            ]
        ]


bodyDiv : Graph -> Coto -> Html Msg
bodyDiv graph coto =
    Components.Coto.bodyDiv 
        graph 
        { openCoto = OpenCoto coto
        , openTraversal = Just OpenTraversal
        , cotonomaClick = CotonomaClick
        , markdown = App.Markdown.markdown
        }
        { cotoId = Just coto.id
        , content = coto.content 
        , asCotonoma = coto.asCotonoma
        , cotonomaKey = coto.cotonomaKey
        }
        

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
                    [ selectionInfoDiv model
                    , div [ class "buttons" ]
                        [ button 
                           [ class "button", onClick ConfirmPin ] 
                           [ i [ class "fa fa-thumb-tack", (attribute "aria-hidden" "true") ] []
                           , text "Pin" 
                           ]
                        , button 
                           [ class "button", onClick (SetConnectMode True) ] 
                           [ text "Connect" ]
                        ]
                    ]
            ]
