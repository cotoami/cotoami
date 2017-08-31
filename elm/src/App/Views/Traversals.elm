module App.Views.Traversals exposing (..)

import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Keyed
import Util.EventUtil exposing (onClickWithoutPropagation, onLinkButtonClick)
import App.Types.Context exposing (CotoSelection, Context)
import App.Types.Coto exposing (Coto, CotoId, Cotonoma)
import App.Types.Graph exposing (Graph, Connection, hasChildren)
import App.Types.Traversal exposing (..)
import App.Messages exposing (..)
import App.Views.Coto


view : Bool -> Context -> Graph -> Traversals -> List (Html Msg)
view activeOnMobile context graph model =
    model.order
        |> List.filterMap
            (\cotoId ->
                case Dict.get cotoId model.entries of
                    Nothing -> Nothing
                    Just traversal ->
                        traversal |> maybeTraversalDiv context graph
            )
        |> List.indexedMap
            (\index traversalDiv ->
                let
                    visibleOnMobile = activeOnMobile && (isActiveIndex index model)
                in
                    div [ classList
                            [ ( "main-column", True )
                            , ( "main-traversal", True )
                            , ( "main-traversal-" ++ (toString index), True )
                            , ( "activeOnMobile", visibleOnMobile )
                            , ( "animated", visibleOnMobile )
                            , ( "fadeIn", visibleOnMobile )
                            , ( "not-in-active-page", not (isActiveIndex index model) )
                            ]
                        ]
                        [ traversalDiv ]
            )
        |> List.reverse
        |> (::) (traversalsPaginationDiv model)


maybeTraversalDiv : Context -> Graph -> Traversal -> Maybe (Html Msg)
maybeTraversalDiv context graph traversal =
    case Dict.get traversal.start graph.cotos of
        Nothing -> Nothing
        Just startCoto ->
            Just <|
              traversalDiv
                  context
                  graph
                  traversal
                  (Dict.get startCoto.id graph.connections
                   |> Maybe.withDefault []
                  )
                  startCoto


traversalDiv : Context -> Graph -> Traversal -> List Connection -> Coto -> Html Msg
traversalDiv context graph traversal connections startCoto  =
    div [ class "traversal" ]
        [ div
            [ class "column-header" ]
            [ span [ class "description" ] []
            , a [ class "tool-button close-traversal"
                , href "/"
                , onLinkButtonClick (CloseTraversal traversal.start)
                ]
                [ i [ class "material-icons" ] [ text "close" ] ]
            ]
        , div
            [ class "column-body" ]
            [ div [ class "traversal-start" ]
                [ traversalStepCotoDiv context graph ( traversal, -1 ) connections startCoto
                ]
            , div [ class "steps" ]
                (List.reverse traversal.steps
                |> List.indexedMap (\index step -> traversalStepDiv context graph step  ( traversal, index ))
                |> List.filterMap identity)
            ]
        ]


traversalStepDiv : Context -> Graph -> CotoId -> ( Traversal, Int ) -> Maybe (Html Msg)
traversalStepDiv context graph cotoId traversalStep =
    case Dict.get cotoId graph.cotos of
        Nothing -> Nothing
        Just coto -> Just
            (div [ class "step" ]
                [ div [ class "arrow" ]
                    [ i [ class "material-icons" ] [ text "arrow_downward" ]
                    ]
                , traversalStepCotoDiv
                    context
                    graph
                    traversalStep
                    (case Dict.get cotoId graph.connections of
                        Nothing -> []
                        Just connections -> connections
                    )
                    coto
                ]
            )


traversalStepCotoDiv : Context -> Graph -> ( Traversal, Int ) -> List Connection -> Coto -> Html Msg
traversalStepCotoDiv context graph ( traversal, index ) connections coto =
    let
        elementId =
            "traversal-" ++ traversal.start ++ "-step-" ++ (toString index)
    in
        div [ App.Views.Coto.cotoClassList context elementId (Just coto.id) []
            , onClickWithoutPropagation (CotoClick elementId coto.id)
            , onMouseEnter (CotoMouseEnter elementId coto.id)
            , onMouseLeave (CotoMouseLeave elementId coto.id)
            ]
            [ div [ class "coto-inner" ]
                  [ App.Views.Coto.headerDiv CotonomaClick context.cotonoma graph coto
                  , App.Views.Coto.bodyDiv Nothing context graph coto
                  , div [ class "main-sub-border" ] []
                  , connectionsDiv ( traversal, index ) coto.id connections context graph
                  ]
            ]


connectionsDiv : ( Traversal, Int ) -> CotoId -> List Connection -> Context -> Graph -> Html Msg
connectionsDiv traversalStep parentId connections context graph =
    Html.Keyed.node
        "div"
        [ class "sub-cotos" ]
        (List.filterMap
            (\conn ->
                case Dict.get conn.end graph.cotos of
                    Nothing -> Nothing  -- Missing the end node
                    Just coto -> Just
                        ( conn.key
                        , connectionDiv traversalStep context graph parentId coto
                        )
            )
            (List.reverse connections)
        )


connectionDiv : ( Traversal, Int ) -> Context -> Graph -> CotoId -> Coto -> Html Msg
connectionDiv ( traversal, index ) context graph parentId coto =
    div [ classList
            [ ( "outbound-conn", True )
            , ( "traversed", traversed index coto.id traversal )
            ]
        ]
        [ subCotoDiv ( traversal, index ) context graph parentId coto ]


subCotoDiv : ( Traversal, Int ) -> Context -> Graph -> CotoId -> Coto -> Html Msg
subCotoDiv ( traversal, index ) context graph parentId coto =
    let
        elementId =
            "traversal-" ++ traversal.start ++ "-step-" ++ (toString index) ++ "-" ++ coto.id
    in
        div
            [ App.Views.Coto.cotoClassList context elementId (Just coto.id) []
            , onClickWithoutPropagation (CotoClick elementId coto.id)
            , onMouseEnter (CotoMouseEnter elementId coto.id)
            , onMouseLeave (CotoMouseLeave elementId coto.id)
            ]
            [ div
                [ class "coto-inner" ]
                [ App.Views.Coto.headerDiv CotonomaClick context.cotonoma graph coto
                , App.Views.Coto.bodyDiv (Just ( parentId, coto.id )) context graph coto
                , traverseButtonDiv TraverseClick index coto.id traversal graph
                ]
            ]


traversalsPaginationDiv : Traversals -> Html Msg
traversalsPaginationDiv model =
    if (App.Types.Traversal.size model) > 1 then
        model.order
            |> List.indexedMap
                (\index cotoId ->
                    div [ class "button-container" ]
                        [ button
                            [ class "button"
                            , disabled (model.activeIndexOnMobile == index)
                            , onClickWithoutPropagation (SwitchTraversal index)
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
            [ a [ onLinkButtonClick (buttonClick (Traverse traversal index cotoId)) ]
                [ i [ class "material-icons" ] [ text "arrow_downward" ]
                ]
            ]
    else
        div [] []
