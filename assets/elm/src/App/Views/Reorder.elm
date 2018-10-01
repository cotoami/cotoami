module App.Views.Reorder
    exposing
        ( update
        , maybeReorderTools
        , reorderTools
        , closeButtonDiv
        )

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Utils.UpdateUtil exposing (..)
import Utils.EventUtil exposing (onLinkButtonClick)
import Utils.HtmlUtil exposing (materialIcon)
import App.Messages as AppMsg
import App.Views.ReorderMsg as ReorderMsg exposing (Msg(..))
import App.Types.Coto exposing (ElementId, CotoId)
import App.Types.Connection exposing (InboundConnection)
import App.Types.Graph
import App.Submodels.Context exposing (Context)
import App.Submodels.LocalCotos exposing (LocalCotos)
import App.Server.Graph


type alias UpdateModel model =
    LocalCotos model


update : Context context -> ReorderMsg.Msg -> UpdateModel model -> ( UpdateModel model, Cmd AppMsg.Msg )
update context msg model =
    case msg of
        SwapOrder maybeParentId index1 index2 ->
            model.graph
                |> App.Types.Graph.swapOrder maybeParentId index1 index2
                |> (\graph -> { model | graph = graph })
                |> withCmd (saveOrder context maybeParentId)

        MoveToFirst maybeParentId index ->
            model.graph
                |> App.Types.Graph.moveToFirst maybeParentId index
                |> (\graph -> { model | graph = graph })
                |> withCmd (saveOrder context maybeParentId)

        MoveToLast maybeParentId index ->
            model.graph
                |> App.Types.Graph.moveToLast maybeParentId index
                |> (\graph -> { model | graph = graph })
                |> withCmd (saveOrder context maybeParentId)

        ConnectionsReordered (Ok _) ->
            model |> withoutCmd

        ConnectionsReordered (Err _) ->
            model |> withoutCmd


saveOrder : Context context -> Maybe CotoId -> UpdateModel model -> Cmd AppMsg.Msg
saveOrder context maybeParentId model =
    model.graph
        |> App.Types.Graph.getOutboundConnections maybeParentId
        |> Maybe.map (List.map (.end))
        |> Maybe.map List.reverse
        |> Maybe.map
            (App.Server.Graph.reorder
                (AppMsg.ReorderMsg << ConnectionsReordered)
                context.clientId
                (Maybe.map (.key) model.cotonoma)
                maybeParentId
            )
        |> Maybe.withDefault Cmd.none


maybeReorderTools : Context a -> Maybe InboundConnection -> ElementId -> Maybe (Html AppMsg.Msg)
maybeReorderTools context maybeInbound elementId =
    maybeInbound
        |> Maybe.map
            (\inbound ->
                if inbound.reordering then
                    Just (reorderTools context inbound elementId)
                else
                    Nothing
            )
        |> Maybe.withDefault
            Nothing


reorderTools : Context a -> InboundConnection -> ElementId -> Html AppMsg.Msg
reorderTools context inbound elementId =
    let
        maybeParentId =
            Maybe.map (.id) inbound.parent

        index =
            inbound.index

        isFirst =
            inbound.index == 0

        isLast =
            inbound.index == (inbound.siblings - 1)
    in
        span [ class "reorder-tool-buttons" ]
            [ a
                [ classList
                    [ ( "tool-button", True )
                    , ( "move-to-top", True )
                    , ( "disabled", isFirst )
                    ]
                , title "Move to the top"
                , onLinkButtonClick
                    (AppMsg.ReorderMsg
                        (MoveToFirst maybeParentId index)
                    )
                ]
                [ materialIcon "skip_previous" Nothing ]
            , a
                [ classList
                    [ ( "tool-button", True )
                    , ( "move-up", True )
                    , ( "disabled", isFirst )
                    ]
                , title "Move up"
                , onLinkButtonClick
                    (AppMsg.ReorderMsg
                        (SwapOrder maybeParentId index (index - 1))
                    )
                ]
                [ materialIcon "play_arrow" Nothing ]
            , a
                [ classList
                    [ ( "tool-button", True )
                    , ( "move-down", True )
                    , ( "disabled", isLast )
                    ]
                , title "Move down"
                , onLinkButtonClick
                    (AppMsg.ReorderMsg
                        (SwapOrder maybeParentId index (index + 1))
                    )
                ]
                [ materialIcon "play_arrow" Nothing ]
            , a
                [ classList
                    [ ( "tool-button", True )
                    , ( "move-to-bottom", True )
                    , ( "disabled", isLast )
                    ]
                , title "Move to the bottom"
                , onLinkButtonClick
                    (AppMsg.ReorderMsg
                        (MoveToLast maybeParentId index)
                    )
                ]
                [ materialIcon "skip_next" Nothing ]
            ]


closeButtonDiv : Context context -> Html AppMsg.Msg
closeButtonDiv context =
    div [ class "close-reordering-button" ]
        [ a
            [ class "tool-button"
            , onClick (AppMsg.CloseReorderMode)
            ]
            [ materialIcon "done" Nothing
            , text "Done reordering"
            ]
        ]
