module Components.Traversals.View exposing (..)

import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Keyed
import Utils exposing (onClickWithoutPropagation)
import App.Types exposing (Coto, CotoId, Cotonoma, CotoSelection)
import App.Graph exposing (..)
import App.Markdown
import Components.Coto
import Components.Traversals.Messages exposing (..)
import Components.Traversals.Model exposing (Model, Traversal, Traverse, traversed, inActivePage)


view : Bool -> CotoSelection -> Maybe Cotonoma -> Graph -> Model -> List (Html Msg)
view activeOnMobile selection maybeCotonoma graph model =
    model.order
    |> List.filterMap
        (\cotoId ->
            case Dict.get cotoId model.traversals of
                Nothing -> Nothing
                Just traversal ->
                    traversal |> maybeTraversalDiv selection maybeCotonoma graph
        )
    |> List.indexedMap 
        (\index traversalDiv -> 
            let
                visibleOnMobile = activeOnMobile && (inActivePage index model)
            in
                div [ classList 
                        [ ( "main-column", True )
                        , ( "main-traversal", True )
                        , ( "main-traversal-" ++ (toString index), True )
                        , ( "activeOnMobile", visibleOnMobile )
                        , ( "animated", visibleOnMobile )
                        , ( "fadeIn", visibleOnMobile )
                        , ( "not-in-active-page", not (inActivePage index model) )
                        ]
                    ] 
                    [ traversalDiv ] 
        )
    |> (::) (traversalsPaginationDiv model)


maybeTraversalDiv : CotoSelection -> Maybe Cotonoma -> Graph -> Traversal -> Maybe (Html Msg)
maybeTraversalDiv selection maybeCotonoma graph traversal =
    case Dict.get traversal.start graph.cotos of
        Nothing -> Nothing
        Just startCoto ->
            Just <|
              traversalDiv 
                  selection
                  maybeCotonoma
                  graph
                  traversal 
                  (Dict.get startCoto.id graph.connections
                   |> Maybe.withDefault []
                  )
                  startCoto 
  

traversalDiv : CotoSelection -> Maybe Cotonoma -> Graph -> Traversal -> List Connection -> Coto -> Html Msg
traversalDiv selection maybeCotonoma graph traversal connections startCoto  =
    div [ class "traversal" ]
        [ div 
            [ class "column-header" ] 
            [ a [ class "tool-button close-traversal"
                , href "/"
                , onClickWithoutPropagation (CloseTraversal traversal.start)
                ]
                [ i [ class "material-icons" ] [ text "close" ] ]
            ]
        , div 
            [ class "column-body" ]
            [ traversalStepCotoDiv selection maybeCotonoma graph ( traversal, -1 ) connections startCoto
            , div [ class "steps" ]
                (List.reverse traversal.steps
                |> List.indexedMap (\index step -> traversalStepDiv selection maybeCotonoma graph step  ( traversal, index )) 
                |> List.filterMap identity)
            ]
        ]
        

traversalStepDiv : CotoSelection -> Maybe Cotonoma -> Graph -> CotoId -> ( Traversal, Int ) -> Maybe (Html Msg)
traversalStepDiv selection maybeCotonoma graph cotoId traversalStep =
    case Dict.get cotoId graph.cotos of
        Nothing -> Nothing
        Just coto -> Just
            (div [ class "step" ]
                [ div [ class "arrow" ]
                    [ i [ class "material-icons" ] [ text "arrow_downward" ]
                    ]
                , traversalStepCotoDiv 
                    selection 
                    maybeCotonoma 
                    graph
                    traversalStep
                    (case Dict.get cotoId graph.connections of
                        Nothing -> []
                        Just connections -> connections
                    )
                    coto 
                ]
            )


traversalStepCotoDiv : CotoSelection -> Maybe Cotonoma -> Graph -> ( Traversal, Int ) -> List Connection -> Coto -> Html Msg
traversalStepCotoDiv selection maybeCotonoma graph traversalStep connections coto =
    div [ classList 
            [ ( "coto", True )
            , ( "selectable", True )
            , ( "active", List.member coto.id selection )
            ]
        ]
        [ div [ class "coto-inner" ]
              [ Components.Coto.headerDiv CotonomaClick maybeCotonoma graph coto
              , bodyDiv graph coto
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
            , bodyDiv graph coto
            , traverseButtonDiv TraverseClick index coto.id traversal graph
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
        

traversalsPaginationDiv : Model -> Html Msg
traversalsPaginationDiv model =
    if (Components.Traversals.Model.countPages model) > 1 then
        model.order
        |> List.indexedMap
            (\index cotoId ->
                div [ class "button-container" ]
                    [ button 
                        [ class "button"
                        , disabled (model.activePageIndex == index)
                        , onClickWithoutPropagation (ChangePage index)
                        ]
                        [ text (toString (index + 1)) ]
                    ]
            )
        |> div [ id "traversals-pagination"]
      else
        div [] []


traverseButtonDiv : (Traverse -> msg) -> Int -> CotoId -> Traversal -> Graph-> Html msg
traverseButtonDiv buttonClick index cotoId traversal graph =
    if hasChildren cotoId graph then
        div [ class "sub-cotos-button" ]
            [ a [ onClickWithoutPropagation (buttonClick (Traverse traversal index cotoId)) ]
                [ i [ class "material-icons" ] [ text "more_horiz" ]
                ]
            ]
    else
        div [] []
