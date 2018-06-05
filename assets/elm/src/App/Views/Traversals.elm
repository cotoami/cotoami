module App.Views.Traversals exposing (..)

import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Keyed
import Util.EventUtil exposing (onClickWithoutPropagation, onLinkButtonClick)
import Util.HtmlUtil exposing (faIcon, materialIcon)
import App.Markdown
import App.Types.Context exposing (CotoSelection, Context)
import App.Types.Coto exposing (Coto, CotoId, Cotonoma)
import App.Types.Graph exposing (Graph, Connection, hasChildren)
import App.Types.Traversal exposing (..)
import App.Messages exposing (..)
import App.Views.Coto exposing (InboundConnection, defaultActionConfig)


view : Bool -> Context -> Graph -> Traversals -> List (Html Msg)
view activeOnMobile context graph model =
    model.order
        |> List.filterMap
            (\cotoId ->
                Dict.get cotoId model.entries
                    |> Maybe.andThen
                        (\traversal -> maybeTraversalDiv context graph traversal)
            )
        |> List.reverse
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
        |> (::) (traversalsPaginationDiv graph model)


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


type alias TraversalStep =
    { traversal : Traversal
    , index : Int
    , cotoId : CotoId
    }


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
                [ parentsDiv graph traversal startCoto.id
                , startCotoDiv context graph traversal connections startCoto
                ]
            , div [ class "steps" ]
                (traversal.steps
                    |> List.reverse
                    |> List.indexedMap
                        (\index codoId ->
                            stepDiv context graph (TraversalStep traversal index codoId)
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
                [ App.Views.Coto.headerDivWithDefaultConfig context graph Nothing elementId coto
                , App.Views.Coto.bodyDivByCoto context elementId coto
                , div [ class "main-sub-border" ] []
                , connectionsDiv
                    context
                    graph
                    (TraversalStep traversal -1 coto.id)
                    elementId
                    coto
                    connections
                ]
            ]


parentsDiv : Graph -> Traversal -> CotoId -> Html Msg
parentsDiv graph traversal childId =
    let
        parents =
            App.Types.Graph.getParents childId graph
    in
        if List.isEmpty parents then
            div [] []
        else
            div [ class "parents-of-start" ]
                [ div [ class "parents" ]
                    (List.map
                        (\parent ->
                            div
                                [ class "parent"
                                , onClick (TraverseToParent traversal parent.id)
                                ]
                                [ text (App.Views.Coto.abbreviate parent) ]
                        )
                        parents
                    )
                , div
                    [ class "arrow" ]
                    [ materialIcon "arrow_downward" Nothing ]
                ]


stepDiv : Context -> Graph -> TraversalStep -> Maybe (Html Msg)
stepDiv context graph step =
    let
        elementIdPrefix =
            "traversal-" ++ step.traversal.start ++ "-step-" ++ (toString step.index)

        connections =
            Dict.get step.cotoId graph.connections |> Maybe.withDefault []
    in
        graph.cotos
            |> Dict.get step.cotoId
            |> Maybe.map
                (\coto ->
                    div [ class ("step step-" ++ (toString step.index)) ]
                        [ div
                            [ class "arrow" ]
                            [ materialIcon "arrow_downward" Nothing ]
                        , div
                            [ class "step-content" ]
                            [ connectionsDiv
                                context
                                graph
                                step
                                elementIdPrefix
                                coto
                                connections
                            ]
                        ]
                )


connectionsDiv : Context -> Graph -> TraversalStep -> String -> Coto -> List Connection -> Html Msg
connectionsDiv context graph step elementIdPrefix parentCoto connections =
    connections
        |> List.reverse
        |> List.indexedMap
            (\connIndex connection ->
                graph.cotos
                    |> Dict.get connection.end
                    |> Maybe.map
                        (\coto ->
                            ( connection.key
                            , div
                                [ classList
                                    [ ( "outbound-conn", True )
                                    , ( "traversed"
                                      , traversed step.index coto.id step.traversal
                                      )
                                    ]
                                ]
                                [ subCotoDiv
                                    context
                                    graph
                                    step
                                    elementIdPrefix
                                    (InboundConnection
                                        (Just parentCoto)
                                        connection
                                        (List.length connections)
                                        connIndex
                                    )
                                    coto
                                ]
                            )
                        )
                    |> Maybe.withDefault
                        ( connection.key, div [] [] )
            )
        |> Html.Keyed.node "div" [ class "sub-cotos" ]


subCotoDiv : Context -> Graph -> TraversalStep -> String -> InboundConnection -> Coto -> Html Msg
subCotoDiv context graph traversalStep elementIdPrefix inbound coto =
    let
        elementId =
            elementIdPrefix ++ "-" ++ coto.id

        maybeParentId =
            inbound.parent |> Maybe.map (\parent -> parent.id)
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
                    (Just inbound)
                    { defaultActionConfig
                        | toggleReorderMode = Just ToggleReorderMode
                    }
                    elementId
                    coto
                , App.Views.Coto.parentsDiv graph maybeParentId coto.id
                , div [ class "sub-coto-body" ]
                    [ App.Views.Coto.bodyDivByCoto context elementId coto
                    , traverseButtonDiv graph traversalStep coto
                    ]
                ]
            ]


traversalsPaginationDiv : Graph -> Traversals -> Html Msg
traversalsPaginationDiv graph model =
    if App.Types.Traversal.isEmpty model then
        div [] []
    else
        model.order
            |> List.reverse
            |> List.indexedMap
                (\index cotoId ->
                    let
                        defaultPageLabel =
                            toString (index + 1)

                        pageLabel =
                            App.Types.Graph.getCoto cotoId graph
                                |> Maybe.map (toPageLabel defaultPageLabel)
                                |> Maybe.withDefault defaultPageLabel
                    in
                        div [ class "button-container" ]
                            [ button
                                [ class "button"
                                , disabled (model.activeIndexOnMobile == index)
                                , onClickWithoutPropagation (SwitchTraversal index)
                                ]
                                [ text pageLabel ]
                            ]
                )
            |> div [ id "traversals-pagination" ]


toPageLabel : String -> Coto -> String
toPageLabel defaultLabel { content, summary } =
    summary
        |> Maybe.withDefault
            (App.Markdown.extractTextFromMarkdown content
                |> List.head
                |> Maybe.withDefault defaultLabel
            )
        |> (String.left 8)


traverseButtonDiv : Graph -> TraversalStep -> Coto -> Html Msg
traverseButtonDiv graph { traversal, index } coto =
    div [ class "sub-cotos-button" ]
        [ if coto.asCotonoma then
            openTraversalButton coto.id
          else if hasChildren coto.id graph then
            a
                [ class "tool-button traverse"
                , onLinkButtonClick (Traverse traversal coto.id index)
                ]
                [ materialIcon "arrow_downward" Nothing ]
          else
            Util.HtmlUtil.none
        ]


openTraversalButton : CotoId -> Html Msg
openTraversalButton cotoId =
    a
        [ class "tool-button open-traversal"
        , onLinkButtonClick (OpenTraversal cotoId)
        ]
        [ materialIcon "arrow_forward" Nothing ]
