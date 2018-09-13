module App.Views.Stock
    exposing
        ( Model
        , defaultModel
        , update
        , renderGraph
        , renderGraphWithDelay
        , resizeGraphWithDelay
        , view
        )

import Dict
import Task
import Process
import Time
import Html exposing (..)
import Html.Keyed
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Exts.Maybe exposing (isJust)
import Util.UpdateUtil exposing (..)
import Util.EventUtil exposing (onClickWithoutPropagation, onLinkButtonClick)
import Util.HtmlUtil exposing (faIcon, materialIcon)
import App.Types.Coto exposing (Coto, CotoId, Cotonoma, CotonomaKey, CotoSelection)
import App.Types.Graph exposing (Graph, Connection)
import App.Messages as AppMsg exposing (..)
import App.Views.StockMsg as StockMsg exposing (Msg(..), StockView(..))
import App.Submodels.Context exposing (Context)
import App.Views.Coto exposing (InboundConnection, defaultActionConfig)
import App.Ports.Graph


type alias Model =
    { view : StockView
    }


defaultModel : Model
defaultModel =
    { view = DocumentView
    }


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


renderGraph : Context context -> UpdateModel model -> Cmd AppMsg.Msg
renderGraph context model =
    if model.stockView.view == GraphView then
        App.Ports.Graph.renderCotoGraph context.cotonoma model.graph
    else
        Cmd.none


renderGraphWithDelay : Cmd AppMsg.Msg
renderGraphWithDelay =
    Process.sleep (100 * Time.millisecond)
        |> Task.andThen (\_ -> Task.succeed ())
        |> Task.perform (\_ -> (AppMsg.StockMsg RenderGraph))


resizeGraphWithDelay : Cmd AppMsg.Msg
resizeGraphWithDelay =
    Process.sleep (100 * Time.millisecond)
        |> Task.andThen (\_ -> Task.succeed ())
        |> Task.perform (\_ -> (AppMsg.StockMsg ResizeGraph))


type alias ViewModel model =
    { model
        | stockView : Model
        , graph : Graph
        , loadingGraph : Bool
    }


view : Context context -> ViewModel model -> Html AppMsg.Msg
view context model =
    div [ id "stock" ]
        [ div
            [ class "column-header" ]
            [ div [ class "view-switch" ]
                [ a
                    [ classList
                        [ ( "tool-button", True )
                        , ( "document-view", True )
                        , ( "disabled", model.stockView.view == DocumentView )
                        ]
                    , onClick (AppMsg.StockMsg (SwitchView DocumentView))
                    ]
                    [ materialIcon "view_stream" Nothing ]
                , a
                    [ classList
                        [ ( "tool-button", True )
                        , ( "graph-view", True )
                        , ( "disabled", model.stockView.view == GraphView )
                        ]
                    , onClick (AppMsg.StockMsg (SwitchView GraphView))
                    ]
                    [ materialIcon "share" Nothing ]
                ]
            ]
        , div
            [ id "pinned-cotos-body", class "column-body" ]
            [ case model.stockView.view of
                DocumentView ->
                    pinnedCotos context model.graph

                GraphView ->
                    div
                        [ id "coto-graph-view"
                        , classList [ ( "loading", model.loadingGraph ) ]
                        ]
                        []
            ]
        ]


pinnedCotos : Context a -> Graph -> Html AppMsg.Msg
pinnedCotos context graph =
    graph.rootConnections
        |> List.reverse
        |> List.indexedMap
            (\index connection ->
                connectionDiv
                    context
                    graph
                    (InboundConnection
                        Nothing
                        connection
                        (List.length graph.rootConnections)
                        index
                    )
            )
        |> Html.Keyed.node "div" [ class "root-connections" ]


connectionDiv : Context a -> Graph -> InboundConnection -> ( String, Html AppMsg.Msg )
connectionDiv context graph inbound =
    graph.cotos
        |> Dict.get inbound.connection.end
        |> Maybe.map
            (\coto ->
                ( inbound.connection.key
                , div
                    [ class "outbound-conn" ]
                    [ cotoDiv context graph inbound coto ]
                )
            )
        |> Maybe.withDefault
            ( inbound.connection.key, div [] [] )


cotoDiv : Context a -> Graph -> InboundConnection -> Coto -> Html AppMsg.Msg
cotoDiv context graph inbound coto =
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
                [ unpinButtonDiv context inbound.connection coto.id
                , App.Views.Coto.headerDiv
                    context
                    graph
                    (Just inbound)
                    { defaultActionConfig
                        | toggleReorderMode = Just ToggleReorderMode
                    }
                    elementId
                    coto
                , App.Views.Coto.parentsDiv graph cotonomaCotoId coto.id
                , App.Views.Coto.bodyDivByCoto context elementId coto
                , App.Views.Coto.subCotosDiv context graph elementId coto
                ]
            ]


unpinButtonDiv : Context a -> Connection -> CotoId -> Html AppMsg.Msg
unpinButtonDiv context connection cotoId =
    let
        maybeAmishiId =
            context.session
                |> Maybe.map (\session -> session.id)

        maybeCotonomaOwnerId =
            context.cotonoma
                |> Maybe.andThen (\cotonoma -> cotonoma.owner)
                |> Maybe.map (\owner -> owner.id)

        unpinnable =
            App.Submodels.Context.isServerOwner context
                || (maybeAmishiId == Just connection.amishiId)
                || ((isJust maybeAmishiId) && maybeAmishiId == maybeCotonomaOwnerId)
    in
        div [ class "unpin-button" ]
            [ if unpinnable then
                a
                    [ class "tool-button unpin"
                    , onLinkButtonClick (ConfirmUnpinCoto cotoId)
                    ]
                    [ faIcon "thumb-tack" Nothing ]
              else
                span
                    [ class "not-unpinnable" ]
                    [ faIcon "thumb-tack" Nothing ]
            ]
