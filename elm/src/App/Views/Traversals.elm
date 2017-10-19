module App.Views.Traversals exposing (..)

import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Keyed
import Util.EventUtil exposing (onClickWithoutPropagation, onLinkButtonClick)
import Util.HtmlUtil exposing (materialIcon)
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
                    Nothing ->
                        Nothing

                    Just traversal ->
                        traversal |> maybeTraversalDiv context graph
            )
        |> List.indexedMap
            (\index traversalDiv ->
                let
                    visibleOnMobile =
                        activeOnMobile && (isActiveIndex index model)
                in
                    div
                        [ classList
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
        Nothing ->
            Nothing

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
traversalDiv context graph traversal connections startCoto =
    div [ class "traversal" ]
        [ div
            [ class "column-header" ]
            [ span [ class "description" ] []
            , a
                [ class "tool-button close-traversal"
                , href "/"
                , onLinkButtonClick (CloseTraversal traversal.start)
                ]
                [ materialIcon "close" Nothing ]
            ]
        , div
            [ class "column-body" ]
            [ div [ class "traversal-start" ]
                [ traversalStepCotoDiv context graph ( traversal, -1 ) connections startCoto
                ]
            , div [ class "steps" ]
                (List.reverse traversal.steps
                    |> List.indexedMap (\index step -> traversalStepDiv context graph step ( traversal, index ))
                    |> List.filterMap identity
                )
            ]
        ]


traversalStepDiv : Context -> Graph -> CotoId -> ( Traversal, Int ) -> Maybe (Html Msg)
traversalStepDiv context graph cotoId traversalStep =
    graph.cotos
        |> Dict.get cotoId
        |> Maybe.map
            (\coto ->
                div [ class "step" ]
                    [ div [ class "arrow" ]
                        [ materialIcon "arrow_downward" Nothing ]
                    , traversalStepCotoDiv
                        context
                        graph
                        traversalStep
                        (Dict.get cotoId graph.connections
                            |> Maybe.withDefault []
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
        div
            [ App.Views.Coto.cotoClassList context elementId (Just coto.id) []
            , onClickWithoutPropagation (CotoClick elementId coto.id)
            , onMouseEnter (CotoMouseEnter elementId coto.id)
            , onMouseLeave (CotoMouseLeave elementId coto.id)
            ]
            [ div [ class "coto-inner" ]
                [ App.Views.Coto.headerDiv CotonomaClick context.cotonoma graph coto
                , App.Views.Coto.bodyDiv context graph Nothing coto
                , div [ class "main-sub-border" ] []
                , connectionsDiv ( traversal, index ) coto connections context graph
                ]
            ]


connectionsDiv : ( Traversal, Int ) -> Coto -> List Connection -> Context -> Graph -> Html Msg
connectionsDiv ( traversal, index ) parentCoto connections context graph =
    Html.Keyed.node
        "div"
        [ class "sub-cotos" ]
        (List.filterMap
            (\connection ->
                graph.cotos
                    |> Dict.get connection.end
                    |> Maybe.map
                        (\coto ->
                            ( connection.key
                            , div
                                [ classList
                                    [ ( "outbound-conn", True )
                                    , ( "traversed", traversed index coto.id traversal )
                                    ]
                                ]
                                [ subCotoDiv
                                    ( traversal, index )
                                    context
                                    graph
                                    ( parentCoto, connection )
                                    coto
                                ]
                            )
                        )
            )
            (List.reverse connections)
        )


subCotoDiv : ( Traversal, Int ) -> Context -> Graph -> ( Coto, Connection ) -> Coto -> Html Msg
subCotoDiv ( traversal, index ) context graph connection coto =
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
                , App.Views.Coto.bodyDiv context graph (Just connection) coto
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
            |> div [ id "traversals-pagination" ]
    else
        div [] []


traverseButtonDiv : (Traverse -> msg) -> Int -> CotoId -> Traversal -> Graph -> Html msg
traverseButtonDiv buttonClick index cotoId traversal graph =
    if hasChildren cotoId graph then
        div [ class "sub-cotos-button" ]
            [ a [ onLinkButtonClick (buttonClick (Traverse traversal index cotoId)) ]
                [ materialIcon "arrow_downward" Nothing ]
            ]
    else
        div [] []
