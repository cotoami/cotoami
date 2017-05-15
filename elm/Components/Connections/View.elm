module Components.Connections.View exposing (..)

import Dict
import Html exposing (..)
import Html.Keyed
import Html.Attributes exposing (..)
import Markdown
import Utils exposing (onClickWithoutPropagation)
import App.Types exposing (Coto, CotoId, Cotonoma, CotoSelection)
import App.Graph exposing (..)
import App.Markdown exposing (markdownOptions, markdownElements)
import Components.Connections.Messages exposing (..)
import Components.Coto


view : Dict.Dict CotoId Traversal -> CotoSelection -> Maybe Cotonoma -> Graph -> Html Msg
view traversals selection maybeCotonoma graph =
    Html.Keyed.node
        "div"
        [ id "connections" ]
        (
          ( "column-roots"
          , div [ id "column-roots", class "connections-column" ]
              [ div [ class "column-header" ] 
                  [ i [ class "pinned fa fa-thumb-tack", (attribute "aria-hidden" "true") ] []
                  ]
              , rootConnections selection maybeCotonoma graph 
              ]
          ) ::
              List.map
                  (\traversalStart ->
                      let
                          coto = Tuple.first traversalStart
                          connections = Tuple.second traversalStart
                      in
                          ( "column-traversal-" ++ toString coto.id
                          , div 
                              [ class "column-traversal connections-column" ]
                              [ traversalDiv
                                  (case Dict.get coto.id traversals of
                                      Nothing -> 
                                          initTraversal coto.id Nothing
                                      Just traversal ->
                                          traversal
                                  )
                                  connections 
                                  coto 
                                  selection 
                                  maybeCotonoma 
                                  graph 
                              ]
                          )  
                  ) 
                  (graph |> getTraversalStarts |> List.reverse)
        )


rootConnections : CotoSelection -> Maybe Cotonoma -> Graph -> Html Msg
rootConnections selection maybeCotonoma graph =
    connectionsDiv 
        "root-connections" 
        graph.rootConnections 
        selection 
        maybeCotonoma 
        graph


traversalDiv : Traversal -> List Connection -> Coto -> CotoSelection -> Maybe Cotonoma -> Graph -> Html Msg
traversalDiv traversal connections coto selection maybeCotonoma graph =
    div [ class "traversal" ]
        [ traversalStepCotoDiv connections coto selection maybeCotonoma graph
        , div [ class "steps" ]
            (List.filterMap 
                (\step -> traversalStepDiv step selection maybeCotonoma graph) 
                (List.reverse traversal.steps)
            )
        ]
  

traversalStepCotoDiv : List Connection -> Coto -> CotoSelection -> Maybe Cotonoma -> Graph -> Html Msg
traversalStepCotoDiv connections coto selection maybeCotonoma graph =
    div (cotoDivAttrs selection coto)
        [ Components.Coto.headerDiv CotonomaClick maybeCotonoma graph coto
        , markdown coto.content
        , div [ class "main-sub-border" ] []
        , connectionsDiv "sub-cotos" connections selection maybeCotonoma graph
        ]
        
        
traversalStepDiv : CotoId -> CotoSelection -> Maybe Cotonoma -> Graph -> Maybe (Html Msg)
traversalStepDiv cotoId selection maybeCotonoma graph =
    case Dict.get cotoId graph.cotos of
        Nothing -> Nothing
        Just coto -> Just
            (div [ class "step" ]
                [ div [] []
                , traversalStepCotoDiv 
                    (case Dict.get cotoId graph.connections of
                        Nothing -> []
                        Just connections -> connections
                    )
                    coto 
                    selection 
                    maybeCotonoma 
                    graph
                ]
            )
            

connectionsDiv : String -> List Connection -> CotoSelection -> Maybe Cotonoma -> Graph -> Html Msg
connectionsDiv divClass connections selection maybeCotonoma graph =
    Html.Keyed.node
        "div"
        [ class divClass ]
        (List.map 
            (\conn ->
                let
                    maybeCoto = Dict.get conn.end graph.cotos
                in
                    ( conn.key
                    , case maybeCoto of
                        Nothing -> div [ class "coto missing" ] [ text "Missing" ]
                        Just coto -> cotoDiv selection maybeCotonoma graph coto
                    )
            ) 
            (List.reverse connections)
        )


cotoDivAttrs : CotoSelection -> Coto -> List (Attribute Msg)
cotoDivAttrs selection coto =
    [ classList 
        [ ( "coto", True )
        , ( "selectable", True )
        , ( "active", List.member coto.id selection )
        ]
    , onClickWithoutPropagation (CotoClick coto.id)
    ] 
    
  
cotoDiv : CotoSelection -> Maybe Cotonoma -> Graph -> Coto -> Html Msg
cotoDiv selection maybeCotonoma graph coto =
    div (cotoDivAttrs selection coto) 
        [ Components.Coto.headerDiv CotonomaClick maybeCotonoma graph coto
        , markdown coto.content
        , Components.Coto.subCotosButtonDiv graph (Just coto.id)
        ]
    

markdown : String -> Html Msg
markdown content =
    div [ class "content" ]
        <| Markdown.customHtml 
            markdownOptions
            markdownElements
            content
