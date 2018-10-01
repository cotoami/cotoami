module App.Views.Reorder
    exposing
        ( Reordering(..)
        , reorderTools
        )

import Html exposing (..)
import Html.Attributes exposing (..)
import Utils.EventUtil exposing (onLinkButtonClick)
import Utils.HtmlUtil exposing (materialIcon)
import App.Messages exposing (..)
import App.Types.Coto exposing (ElementId)
import App.Submodels.Context exposing (Context)
import App.Types.Graph exposing (InboundConnection)


type Reordering
    = PinnedCotos
    | SubCotos ElementId


reorderTools : Context a -> InboundConnection -> ElementId -> Html Msg
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
                , onLinkButtonClick (MoveToFirst maybeParentId index)
                ]
                [ materialIcon "skip_previous" Nothing ]
            , a
                [ classList
                    [ ( "tool-button", True )
                    , ( "move-up", True )
                    , ( "disabled", isFirst )
                    ]
                , title "Move up"
                , onLinkButtonClick (SwapOrder maybeParentId index (index - 1))
                ]
                [ materialIcon "play_arrow" Nothing ]
            , a
                [ classList
                    [ ( "tool-button", True )
                    , ( "move-down", True )
                    , ( "disabled", isLast )
                    ]
                , title "Move down"
                , onLinkButtonClick (SwapOrder maybeParentId index (index + 1))
                ]
                [ materialIcon "play_arrow" Nothing ]
            , a
                [ classList
                    [ ( "tool-button", True )
                    , ( "move-to-bottom", True )
                    , ( "disabled", isLast )
                    ]
                , title "Move to the bottom"
                , onLinkButtonClick (MoveToLast maybeParentId index)
                ]
                [ materialIcon "skip_next" Nothing ]
            , a
                [ class "tool-button close"
                , title "Close reorder tools"
                , onLinkButtonClick (ToggleReorderMode elementId)
                ]
                [ materialIcon "close" Nothing ]
            ]
