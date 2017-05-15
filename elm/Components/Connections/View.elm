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
        Nothing
        "root-connections" 
        graph.rootConnections 
        selection 
        maybeCotonoma 
        graph


traversalDiv : Traversal -> List Connection -> Coto -> CotoSelection -> Maybe Cotonoma -> Graph -> Html Msg
traversalDiv traversal connections coto selection maybeCotonoma graph =
    div [ class "traversal" ]
        [ traversalStepCotoDiv -1 connections coto selection maybeCotonoma graph
        , div [ class "steps" ]
            (List.reverse traversal.steps
            |> List.indexedMap (\index step -> traversalStepDiv index step selection maybeCotonoma graph) 
            |> List.filterMap identity
            )
        ]
  

traversalStepCotoDiv : Int -> List Connection -> Coto -> CotoSelection -> Maybe Cotonoma -> Graph -> Html Msg
traversalStepCotoDiv index connections coto selection maybeCotonoma graph =
    div (cotoDivAttrs selection coto)
        [ Components.Coto.headerDiv CotonomaClick maybeCotonoma graph coto
        , markdown coto.content
        , div [ class "main-sub-border" ] []
        , connectionsDiv (Just index) "sub-cotos" connections selection maybeCotonoma graph
        ]
        
        
traversalStepDiv : Int -> CotoId -> CotoSelection -> Maybe Cotonoma -> Graph -> Maybe (Html Msg)
traversalStepDiv index cotoId selection maybeCotonoma graph =
    case Dict.get cotoId graph.cotos of
        Nothing -> Nothing
        Just coto -> Just
            (div [ class "step" ]
                [ div [] []
                , traversalStepCotoDiv 
                    index
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
            

connectionsDiv : Maybe Int -> String -> List Connection -> CotoSelection -> Maybe Cotonoma -> Graph -> Html Msg
connectionsDiv maybeTraversalIndex divClass connections selection maybeCotonoma graph =
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
                        Nothing -> 
                            div [ class "coto missing" ] [ text "Missing" ]
                        Just coto -> 
                            cotoDiv maybeTraversalIndex selection maybeCotonoma graph coto
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
    
  
cotoDiv : Maybe Int -> CotoSelection -> Maybe Cotonoma -> Graph -> Coto -> Html Msg
cotoDiv maybeTraversalIndex selection maybeCotonoma graph coto =
    div (cotoDivAttrs selection coto) 
        [ Components.Coto.headerDiv CotonomaClick maybeCotonoma graph coto
        , markdown coto.content
        , case maybeTraversalIndex of
            Nothing ->
                Components.Coto.openTraversalButtonDiv OpenTraversal (Just coto.id) graph 
            Just index -> 
                Components.Coto.traverseButtonDiv Traverse index coto.id graph
        ]
    

markdown : String -> Html Msg
markdown content =
    div [ class "content" ]
        <| Markdown.customHtml 
            markdownOptions
            markdownElements
            content
