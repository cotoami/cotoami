module App.Views.Traversals exposing (..)

import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Keyed
import Util.EventUtil exposing (onClickWithoutPropagation, onLinkButtonClick)
import Util.HtmlUtil exposing (faIcon, materialIcon)
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
                Dict.get cotoId model.entries
                    |> Maybe.andThen
                        (\traversal -> maybeTraversalDiv context graph traversal)
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
    Dict.get traversal.start graph.cotos
        |> Maybe.map
            (\startCoto ->
                traversalDiv
                    context
                    graph
                    traversal
                    (Dict.get startCoto.id graph.connections
                        |> Maybe.withDefault []
                    )
                    startCoto
            )


traversalDiv : Context -> Graph -> Traversal -> List Connection -> Coto -> Html Msg
traversalDiv context graph traversal connections startCoto =
    div [ class "traversal" ]
        [ div
            [ class "column-header" ]
            [ span [ class "description", title "Coto Graph Exploration" ]
                [ faIcon "sitemap" Nothing
                ]
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
                [ startCotoDiv context graph traversal connections startCoto
                ]
            , div [ class "steps" ]
                (List.reverse traversal.steps
                    |> List.indexedMap
                        (\index step ->
                            stepDiv context graph step ( traversal, index )
                        )
                    |> List.filterMap identity
                )
            ]
        ]


startCotoDiv : Context -> Graph -> Traversal -> List Connection -> Coto -> Html Msg
startCotoDiv context graph traversal connections coto =
    let
        elementId =
            "traversal-" ++ traversal.start
    in
        div
            [ App.Views.Coto.cotoClassList context elementId (Just coto.id) []
            , onClickWithoutPropagation (CotoClick elementId coto.id)
            , onMouseEnter (CotoMouseEnter elementId coto.id)
            , onMouseLeave (CotoMouseLeave elementId coto.id)
            ]
            [ div [ class "coto-inner" ]
                [ App.Views.Coto.headerDivWithDefaultConfig context graph Nothing coto
                , App.Views.Coto.bodyDivByCoto context elementId coto
                , div [ class "main-sub-border" ] []
                , connectionsDiv context graph ( traversal, -1 ) elementId coto connections
                ]
            ]


stepDiv : Context -> Graph -> CotoId -> ( Traversal, Int ) -> Maybe (Html Msg)
stepDiv context graph cotoId ( traversal, index ) =
    let
        elementIdPrefix =
            "traversal-" ++ traversal.start ++ "-step-" ++ (toString index)

        connections =
            Dict.get cotoId graph.connections |> Maybe.withDefault []
    in
        graph.cotos
            |> Dict.get cotoId
            |> Maybe.map
                (\coto ->
                    div [ class "step" ]
                        [ div
                            [ class "arrow" ]
                            [ materialIcon "arrow_downward" Nothing ]
                        , div
                            [ class "step-content" ]
                            [ connectionsDiv
                                context
                                graph
                                ( traversal, index )
                                elementIdPrefix
                                coto
                                connections
                            ]
                        ]
                )


connectionsDiv : Context -> Graph -> ( Traversal, Int ) -> String -> Coto -> List Connection -> Html Msg
connectionsDiv context graph ( traversal, index ) elementIdPrefix parentCoto connections =
    List.reverse connections
        |> (List.filterMap (connectionDiv context graph ( traversal, index ) elementIdPrefix parentCoto))
        |> Html.Keyed.node "div" [ class "sub-cotos" ]


connectionDiv : Context -> Graph -> ( Traversal, Int ) -> String -> Coto -> Connection -> Maybe ( String, Html Msg )
connectionDiv context graph ( traversal, index ) elementIdPrefix parentCoto connection =
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
                        context
                        graph
                        ( traversal, index )
                        elementIdPrefix
                        ( parentCoto, connection )
                        coto
                    ]
                )
            )


subCotoDiv : Context -> Graph -> ( Traversal, Int ) -> String -> ( Coto, Connection ) -> Coto -> Html Msg
subCotoDiv context graph ( traversal, index ) elementIdPrefix connection coto =
    let
        elementId =
            elementIdPrefix ++ "-" ++ coto.id
    in
        div
            [ App.Views.Coto.cotoClassList context elementId (Just coto.id) []
            , onClickWithoutPropagation (CotoClick elementId coto.id)
            , onMouseEnter (CotoMouseEnter elementId coto.id)
            , onMouseLeave (CotoMouseLeave elementId coto.id)
            ]
            [ div
                [ class "coto-inner" ]
                [ App.Views.Coto.headerDiv
                    context
                    graph
                    (Just connection)
                    App.Views.Coto.defaultActionConfig
                    coto
                , App.Views.Coto.bodyDivByCoto context elementId coto
                , traverseButtonDiv graph ( traversal, index ) coto
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


traverseButtonDiv : Graph -> ( Traversal, Int ) -> Coto -> Html Msg
traverseButtonDiv graph ( traversal, index ) coto =
    div [ class "sub-cotos-button" ]
        (if coto.asCotonoma then
            [ openTraversalButton coto.id ]
         else
            (if hasChildren coto.id graph then
                [ a
                    [ class "tool-button traverse"
                    , onLinkButtonClick (TraverseClick (Traverse traversal index coto.id))
                    ]
                    [ materialIcon "arrow_downward" Nothing ]
                , openTraversalButton coto.id
                ]
             else
                []
            )
        )


openTraversalButton : CotoId -> Html Msg
openTraversalButton cotoId =
    a
        [ class "tool-button open-traversal"
        , onLinkButtonClick (OpenTraversal cotoId)
        ]
        [ materialIcon "arrow_forward" Nothing ]
