module Components.Traversal.View exposing (..)

import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Keyed
import Utils exposing (onClickWithoutPropagation)
import App.Types exposing (Coto, CotoId, Cotonoma, CotoSelection)
import App.Graph exposing (..)
import App.Markdown
import Components.Coto
import Components.Traversal.Messages exposing (..)


view : Traversal -> CotoSelection -> Maybe Cotonoma -> Graph -> Maybe (Html Msg)
view traversal selection maybeCotonoma graph =
    case Dict.get traversal.start graph.cotos of
        Nothing -> Nothing
        Just startCoto ->
            Just <|
              traversalDiv 
                  traversal 
                  selection 
                  maybeCotonoma
                  (Dict.get startCoto.id graph.connections
                   |> Maybe.withDefault []
                  )
                  startCoto 
                  graph                    
  

traversalDiv : Traversal -> CotoSelection -> Maybe Cotonoma -> List Connection -> Coto -> Graph -> Html Msg
traversalDiv traversal selection maybeCotonoma connections startCoto graph =
    div [ class "traversal" ]
        [ traversalStepCotoDiv ( traversal, -1 ) connections startCoto selection maybeCotonoma graph
        , div [ class "steps" ]
            (List.reverse traversal.steps
            |> List.indexedMap (\index step -> traversalStepDiv ( traversal, index ) step selection maybeCotonoma graph) 
            |> List.filterMap identity)
        ]
        

traversalStepDiv : ( Traversal, Int ) -> CotoId -> CotoSelection -> Maybe Cotonoma -> Graph -> Maybe (Html Msg)
traversalStepDiv traversalStep cotoId selection maybeCotonoma graph =
    case Dict.get cotoId graph.cotos of
        Nothing -> Nothing
        Just coto -> Just
            (div [ class "step" ]
                [ div [ class "arrow" ]
                    [ i [ class "material-icons" ] [ text "arrow_downward" ]
                    ]
                , traversalStepCotoDiv 
                    traversalStep
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


traversalStepCotoDiv : ( Traversal, Int ) -> List Connection -> Coto -> CotoSelection -> Maybe Cotonoma -> Graph -> Html Msg
traversalStepCotoDiv traversalStep connections coto selection maybeCotonoma graph =
    div [ classList 
            [ ( "coto", True )
            , ( "selectable", True )
            , ( "active", List.member coto.id selection )
            ]
        ]
        [ div [ class "coto-inner" ]
              [ Components.Coto.headerDiv CotonomaClick maybeCotonoma graph coto
              , App.Markdown.markdown coto.content
              , div [ class "main-sub-border" ] []
              , connectionsDiv traversalStep "sub-cotos" connections selection maybeCotonoma graph
              ]
        ]


connectionsDiv : ( Traversal, Int ) -> String -> List Connection -> CotoSelection -> Maybe Cotonoma -> Graph -> Html Msg
connectionsDiv traversalStep divClass connections selection maybeCotonoma graph =
    Html.Keyed.node
        "div"
        [ class divClass ]
        (List.filterMap 
            (\conn ->
                case Dict.get conn.end graph.cotos of
                    Nothing -> Nothing  -- Missing the end node
                    Just coto -> Just 
                        ( conn.key
                        , connectionDiv traversalStep selection maybeCotonoma graph coto
                        ) 
            ) 
            (List.reverse connections)
        )
        
        
connectionDiv : ( Traversal, Int ) -> CotoSelection -> Maybe Cotonoma -> Graph -> Coto -> Html Msg
connectionDiv ( traversal, index ) selection maybeCotonoma graph coto =
    div [ classList 
            [ ( "outbound-conn", True )
            , ( "traversed", traversed index coto.id traversal )
            ]
        ]
        [ cotoDiv ( traversal, index ) selection maybeCotonoma graph coto ]
        
  
cotoDiv : ( Traversal, Int ) -> CotoSelection -> Maybe Cotonoma -> Graph -> Coto -> Html Msg
cotoDiv ( traversal, index ) selection maybeCotonoma graph coto =
    div 
        [ classList 
            [ ( "coto", True )
            , ( "selectable", True )
            , ( "active", List.member coto.id selection )
            ]
        , onClickWithoutPropagation (CotoClick coto.id)
        ]
        [ div 
            [ class "coto-inner" ]
            [ Components.Coto.headerDiv CotonomaClick maybeCotonoma graph coto
            , App.Markdown.markdown coto.content
            , Components.Coto.traverseButtonDiv TraverseClick index coto.id traversal graph
            ]
        ]
