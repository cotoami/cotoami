module App.Views.CotoToolbar
    exposing
        ( view
        )

import Set
import Html exposing (..)
import Html.Attributes exposing (..)
import Utils.EventUtil exposing (onLinkButtonClick)
import Utils.HtmlUtil exposing (faIcon, materialIcon)
import App.Types.Session exposing (Session)
import App.Types.Coto exposing (Coto, ElementId, CotoId)
import App.Types.Graph exposing (Graph, Connection, InboundConnection, Direction(..))
import App.Messages exposing (..)
import App.Submodels.Context exposing (Context)


view :
    Context a
    -> Session
    -> Graph
    -> Maybe InboundConnection
    -> ElementId
    -> Coto
    -> Html Msg
view context session graph maybeInbound elementId coto =
    span [ class "coto-tool-buttons" ]
        [ if
            not (List.isEmpty context.selection)
                && not (App.Submodels.Context.isSelected (Just coto.id) context)
          then
            span [ class "connecting-buttons" ]
                [ a
                    [ class "tool-button connect"
                    , title "Connect"
                    , onLinkButtonClick (ConfirmConnect coto.id Inbound)
                    ]
                    [ faIcon "link" Nothing ]
                , span [ class "border" ] []
                ]
          else
            Utils.HtmlUtil.none
        , maybeInbound
            |> Maybe.map (\inbound -> subCotoTools context session graph inbound elementId coto)
            |> Maybe.withDefault Utils.HtmlUtil.none
        , span [ class "default-buttons" ]
            [ if
                not (App.Types.Graph.pinned coto.id graph)
                    && ((Just coto.id) /= (Maybe.map (.cotoId) context.cotonoma))
              then
                a
                    [ class "tool-button pin-coto"
                    , title "Pin"
                    , onLinkButtonClick (PinCoto coto.id)
                    ]
                    [ faIcon "thumb-tack" Nothing ]
              else
                Utils.HtmlUtil.none
            , if App.Types.Coto.checkWritePermission session coto then
                a
                    [ class "tool-button edit-coto"
                    , title "Edit"
                    , onLinkButtonClick (OpenEditorModal coto)
                    ]
                    [ materialIcon "edit" Nothing ]
              else
                Utils.HtmlUtil.none
            , a
                [ class "tool-button add-coto"
                , title "Create a connected Coto"
                , onLinkButtonClick (OpenNewEditorModalWithSourceCoto coto)
                ]
                [ materialIcon "add" Nothing ]
            , a
                [ class "tool-button select-coto"
                , title "Select"
                , onLinkButtonClick (SelectCoto coto.id)
                ]
                [ materialIcon
                    (if
                        App.Submodels.Context.isSelected (Just coto.id) context
                            && not (Set.member coto.id context.deselecting)
                     then
                        "check_box"
                     else
                        "check_box_outline_blank"
                    )
                    Nothing
                ]
            , a
                [ class "tool-button open-coto-menu"
                , title "More"
                , onLinkButtonClick (OpenCotoMenuModal coto)
                ]
                [ materialIcon "more_horiz" Nothing ]
            ]
        ]


subCotoTools :
    Context a
    -> Session
    -> Graph
    -> InboundConnection
    -> ElementId
    -> Coto
    -> Html Msg
subCotoTools context session graph inbound elementId coto =
    [ inbound.parent
        |> Maybe.map
            (\parent ->
                if isDisconnectable session parent inbound.connection coto then
                    a
                        [ class "tool-button delete-connection"
                        , title "Disconnect"
                        , onLinkButtonClick (ConfirmDeleteConnection ( parent.id, coto.id ))
                        ]
                        [ faIcon "unlink" Nothing ]
                else
                    Utils.HtmlUtil.none
            )
        |> Maybe.withDefault Utils.HtmlUtil.none
    , if isReorderble context session inbound coto then
        a
            [ class "tool-button toggle-reorder-mode"
            , title "Reorder"
            , onLinkButtonClick (ToggleReorderMode elementId)
            ]
            [ faIcon "sort" Nothing ]
      else
        Utils.HtmlUtil.none
    ]
        |> (\buttons ->
                if List.isEmpty buttons then
                    []
                else
                    buttons ++ [ span [ class "border" ] [] ]
           )
        |> span [ class "sub-coto-buttons" ]


isDisconnectable : Session -> Coto -> Connection -> Coto -> Bool
isDisconnectable session parent connection child =
    session.owner
        || (session.id == connection.amishiId)
        || ((Just session.id) == Maybe.map (\amishi -> amishi.id) parent.amishi)


isReorderble : Context a -> Session -> InboundConnection -> Coto -> Bool
isReorderble context session inbound child =
    if inbound.siblings < 2 then
        False
    else if session.owner then
        True
    else
        inbound.parent
            |> Maybe.map
                (\parent ->
                    Just session.id
                        == (parent.amishi
                                |> Maybe.map (\amishi -> amishi.id)
                           )
                )
            |> Maybe.withDefault
                (context.cotonoma
                    |> Maybe.map
                        (\cotonoma ->
                            Just session.id
                                == (cotonoma.owner
                                        |> Maybe.map (\owner -> owner.id)
                                   )
                        )
                    |> Maybe.withDefault True
                )
