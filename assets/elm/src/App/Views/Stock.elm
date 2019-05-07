module App.Views.Stock exposing
    ( Model
    , defaultModel
    , renderGraph
    , renderGraphWithDelay
    , resizeGraphWithDelay
    , update
    , view
    )

import App.Commands
import App.I18n.Keys as I18nKeys
import App.Messages as AppMsg exposing (..)
import App.Ports.Graph
import App.Server.Graph
import App.Submodels.Context exposing (Context)
import App.Types.Connection exposing (Connection, InboundConnection, Reordering(..))
import App.Types.Coto exposing (Coto, CotoId, Cotonoma)
import App.Types.Graph exposing (Graph)
import App.Types.Graph.Render
import App.Views.Coto
import App.Views.Reorder
import App.Views.StockMsg as StockMsg exposing (Msg(..), StockView(..))
import Dict
import Exts.Maybe exposing (isJust)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Keyed
import Process
import Task
import Time
import Utils.EventUtil exposing (onClickWithoutPropagation, onLinkButtonClick)
import Utils.HtmlUtil exposing (faIcon, materialIcon)
import Utils.UpdateUtil exposing (..)


type alias Model =
    { view : StockView
    , graphCanvasFullyOpened : Bool
    }


defaultModel : Model
defaultModel =
    { view = DocumentView
    , graphCanvasFullyOpened = False
    }


view : Context context -> Model -> Html AppMsg.Msg
view context model =
    div [ id "stock" ]
        [ div
            [ class "column-header" ]
            [ div [ class "view-switch" ]
                [ a
                    [ classList
                        [ ( "tool-button", True )
                        , ( "document-view", True )
                        , ( "disabled", model.view == DocumentView )
                        ]
                    , title (context.i18nText I18nKeys.Stock_DocumentView)
                    , onClick (AppMsg.StockMsg (SwitchView DocumentView))
                    ]
                    [ materialIcon "view_headline" Nothing ]
                , a
                    [ classList
                        [ ( "tool-button", True )
                        , ( "graph-view", True )
                        , ( "disabled", model.view == GraphView )
                        ]
                    , title (context.i18nText I18nKeys.Stock_GraphView)
                    , onClick (AppMsg.StockMsg (SwitchView GraphView))
                    ]
                    [ img [ class "graph", src "/images/graph-button.svg" ] []
                    ]
                ]
            , if App.Submodels.Context.hasPinnedCotosInReordering context then
                App.Views.Reorder.closeButtonDiv context

              else
                Utils.HtmlUtil.none
            ]
        , div
            [ id "pinned-cotos-body", class "column-body" ]
            [ case model.view of
                DocumentView ->
                    documentViewDiv context

                GraphView ->
                    graphViewDiv context model
            ]
        ]


documentViewDiv : Context context -> Html AppMsg.Msg
documentViewDiv context =
    context.graph.rootConnections
        |> List.reverse
        |> List.indexedMap
            (\index connection ->
                rootConnectionDiv
                    context
                    (InboundConnection
                        Nothing
                        Nothing
                        connection
                        (List.length context.graph.rootConnections)
                        index
                        (App.Submodels.Context.hasPinnedCotosInReordering context)
                    )
            )
        |> Html.Keyed.node "div" [ class "root-connections" ]


rootConnectionDiv : Context context -> InboundConnection -> ( String, Html AppMsg.Msg )
rootConnectionDiv context inbound =
    context.graph.cotos
        |> Dict.get inbound.connection.end
        |> Maybe.map
            (\coto ->
                ( App.Types.Connection.makeUniqueKey inbound.connection
                , div
                    [ class "outbound-conn" ]
                    [ pinnedCotoDiv context inbound coto ]
                )
            )
        |> Maybe.withDefault
            ( App.Types.Connection.makeUniqueKey inbound.connection
            , Utils.HtmlUtil.none
            )


pinnedCotoDiv : Context context -> InboundConnection -> Coto -> Html AppMsg.Msg
pinnedCotoDiv context inbound coto =
    let
        elementId =
            "pinned-" ++ coto.id

        cotonomaCotoId =
            context.cotonoma |> Maybe.map (\cotonoma -> cotonoma.cotoId)
    in
    div
        [ App.Views.Coto.cotoClassList context
            elementId
            (Just coto.id)
            [ ( "pinned-coto", True )
            , ( "animated", True )
            , ( "fadeIn", True )
            ]
        , onClickWithoutPropagation (CotoClick elementId coto.id)
        , onMouseEnter (CotoMouseEnter elementId coto.id)
        , onMouseLeave (CotoMouseLeave elementId coto.id)
        ]
        [ div
            [ class "coto-inner" ]
            [ pinDiv context inbound.connection coto
            , App.Views.Coto.headerDiv context (Just inbound) elementId coto
            , App.Views.Coto.parentsDiv context.graph cotonomaCotoId coto.id
            , App.Views.Coto.bodyDivByCoto context (Just inbound) elementId coto
            , if inbound.reordering then
                Utils.HtmlUtil.none

              else
                App.Views.Coto.subCotosDiv context elementId coto
            ]
        ]


pinDiv : Context context -> Connection -> Coto -> Html AppMsg.Msg
pinDiv context connection coto =
    let
        maybeAmishiId =
            context.session
                |> Maybe.map (\session -> session.amishi.id)

        maybeCotonomaOwnerId =
            context.cotonoma
                |> Maybe.andThen (\cotonoma -> cotonoma.owner)
                |> Maybe.map (\owner -> owner.id)

        editable =
            App.Submodels.Context.isServerOwner context
                || (maybeAmishiId == Just connection.amishiId)
                || (isJust maybeAmishiId && maybeAmishiId == maybeCotonomaOwnerId)

        msgOnClick =
            context.cotonoma
                |> Maybe.map
                    (\cotonoma ->
                        AppMsg.OpenConnectionModal
                            connection
                            (App.Types.Coto.toCoto cotonoma)
                            coto
                    )
                |> Maybe.withDefault (ConfirmUnpinCoto coto.id)
    in
    connection.linkingPhrase
        |> Maybe.map (linkingPhrasePinDiv editable msgOnClick)
        |> Maybe.withDefault (defaultPinDiv editable msgOnClick)


defaultPinDiv : Bool -> msg -> Html msg
defaultPinDiv editable msgOnClick =
    div [ class "pin" ]
        [ if editable then
            a
                [ class "pin tool-button"
                , onLinkButtonClick msgOnClick
                ]
                [ faIcon "thumb-tack" Nothing ]

          else
            span
                [ class "pin" ]
                [ faIcon "thumb-tack" Nothing ]
        ]


linkingPhrasePinDiv : Bool -> msg -> String -> Html msg
linkingPhrasePinDiv editable msgOnClick linkingPhrase =
    div [ class "linking-phrase-pin" ]
        [ if editable then
            a
                [ class "linking-phrase-pin tool-button"
                , onLinkButtonClick msgOnClick
                ]
                [ text linkingPhrase ]

          else
            span
                [ class "linking-phrase-pin" ]
                [ text linkingPhrase ]
        ]


graphViewDiv : Context context -> Model -> Html AppMsg.Msg
graphViewDiv context model =
    div
        [ id "coto-graph"
        , classList
            [ ( "full-open", model.graphCanvasFullyOpened )
            , ( "loading", context.loadingGraph )
            ]
        ]
        [ div [ class "tools" ]
            [ button
                [ class "toggle-canvas-size"
                , onClick (AppMsg.StockMsg ToggleGraphCanvasSize)
                ]
                [ materialIcon
                    (if model.graphCanvasFullyOpened then
                        "fullscreen_exit"

                     else
                        "fullscreen"
                    )
                    Nothing
                ]
            ]
        , if
            model.graphCanvasFullyOpened
                && App.Types.Graph.hasSubgraphsLoading context.graph
          then
            div [ class "loading-subgraphs" ] [ Utils.HtmlUtil.loadingImg ]

          else
            Utils.HtmlUtil.none
        , div [ id "coto-graph-canvas" ] []
        ]


type alias UpdateModel model =
    { model
        | stockView : Model
        , graph : Graph
    }


update : Context context -> StockMsg.Msg -> UpdateModel model -> ( UpdateModel model, Cmd AppMsg.Msg )
update context msg ({ stockView } as model) =
    case msg of
        SwitchView view ->
            { model | stockView = { stockView | view = view } }
                |> withCmdIf
                    (\_ -> view == GraphView)
                    (\_ -> renderGraphWithDelay)

        RenderGraph ->
            model |> withCmd (\_ -> renderGraph context model)

        ResizeGraph ->
            model
                |> withCmdIf
                    (\model -> model.stockView.view == GraphView)
                    (\_ -> App.Ports.Graph.resizeGraph ())

        ToggleGraphCanvasSize ->
            { model
                | stockView =
                    { stockView
                        | graphCanvasFullyOpened = not stockView.graphCanvasFullyOpened
                    }
            }
                |> withoutCmd

        GraphNodeClicked cotoId ->
            if stockView.graphCanvasFullyOpened then
                App.Server.Graph.fetchSubgraphIfCotonoma
                    (App.Types.Graph.getCoto cotoId model.graph)
                    model.graph
                    |> Tuple.mapFirst (\graph -> { model | graph = graph })

            else
                ( model, App.Commands.sendMsg (AppMsg.OpenTraversal cotoId) )


renderGraph : Context context -> UpdateModel model -> Cmd AppMsg.Msg
renderGraph context model =
    if model.stockView.view == GraphView then
        App.Types.Graph.Render.render context model.graph

    else
        Cmd.none


renderGraphWithDelay : Cmd AppMsg.Msg
renderGraphWithDelay =
    Process.sleep (100 * Time.millisecond)
        |> Task.andThen (\_ -> Task.succeed ())
        |> Task.perform (\_ -> AppMsg.StockMsg RenderGraph)


resizeGraphWithDelay : Cmd AppMsg.Msg
resizeGraphWithDelay =
    Process.sleep (100 * Time.millisecond)
        |> Task.andThen (\_ -> Task.succeed ())
        |> Task.perform (\_ -> AppMsg.StockMsg ResizeGraph)
