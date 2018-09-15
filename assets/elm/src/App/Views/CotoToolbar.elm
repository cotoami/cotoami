module App.Views.CotoToolbar
    exposing
        ( update
        , view
        )

import Set
import Html exposing (..)
import Html.Attributes exposing (..)
import Utils.EventUtil exposing (onLinkButtonClick)
import Utils.HtmlUtil exposing (faIcon, materialIcon)
import App.Types.Session exposing (Session)
import App.Types.Coto exposing (Coto, ElementId, CotoId)
import App.Types.Graph exposing (Graph, Connection, InboundConnection, Direction(..))
import App.Messages as AppMsg exposing (..)
import App.Views.CotoToolbarMsg as CotoToolbarMsg exposing (Msg(..))
import App.Submodels.Context exposing (Context)
import App.Submodels.Modals exposing (Modals)
import App.Submodels.LocalCotos exposing (LocalCotos)
import App.Modals.ConnectModal exposing (WithConnectModal)


type alias UpdateModel model =
    LocalCotos (Modals (WithConnectModal model))


update : Context context -> CotoToolbarMsg.Msg -> UpdateModel model -> ( UpdateModel model, Cmd AppMsg.Msg )
update context msg model =
    case msg of
        ConfirmConnect cotoId direction ->
            model
                |> App.Submodels.LocalCotos.getCoto cotoId
                |> Maybe.map
                    (\coto ->
                        App.Modals.ConnectModal.open
                            direction
                            (App.Modals.ConnectModal.Coto coto)
                            model
                    )
                |> Maybe.withDefault ( model, Cmd.none )


view :
    Context context
    -> Session
    -> Graph
    -> Maybe InboundConnection
    -> ElementId
    -> Coto
    -> Html AppMsg.Msg
view context session graph maybeInbound elementId coto =
    span [ class "coto-tool-buttons" ]
        [ connectButton context coto
        , maybeInbound
            |> Maybe.map (\inbound -> subCotoTools context session graph inbound elementId coto)
            |> Maybe.withDefault Utils.HtmlUtil.none
        , span [ class "default-buttons" ]
            [ pinButton context graph coto
            , editButton context session coto
            , addSubCotoButton context coto
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
    Context context
    -> Session
    -> Graph
    -> InboundConnection
    -> ElementId
    -> Coto
    -> Html AppMsg.Msg
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


isReorderble : Context context -> Session -> InboundConnection -> Coto -> Bool
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


connectButton : Context context -> Coto -> Html AppMsg.Msg
connectButton context coto =
    if
        not (List.isEmpty context.selection)
            && not (App.Submodels.Context.isSelected (Just coto.id) context)
    then
        span [ class "connecting-buttons" ]
            [ a
                [ class "tool-button connect"
                , title "Connect"
                , onLinkButtonClick
                    (AppMsg.CotoToolbarMsg (ConfirmConnect coto.id Inbound))
                ]
                [ faIcon "link" Nothing ]
            , span [ class "border" ] []
            ]
    else
        Utils.HtmlUtil.none


pinButton : Context context -> Graph -> Coto -> Html AppMsg.Msg
pinButton context graph coto =
    if
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


editButton : Context context -> Session -> Coto -> Html AppMsg.Msg
editButton context session coto =
    if App.Types.Coto.checkWritePermission session coto then
        a
            [ class "tool-button edit-coto"
            , title "Edit"
            , onLinkButtonClick (OpenEditorModal coto)
            ]
            [ materialIcon "edit" Nothing ]
    else
        Utils.HtmlUtil.none


addSubCotoButton : Context context -> Coto -> Html AppMsg.Msg
addSubCotoButton context coto =
    a
        [ class "tool-button add-coto"
        , title "Create a connected Coto"
        , onLinkButtonClick (OpenNewEditorModalWithSourceCoto coto)
        ]
        [ materialIcon "add" Nothing ]
