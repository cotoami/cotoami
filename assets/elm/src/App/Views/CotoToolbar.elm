module App.Views.CotoToolbar exposing
    ( update
    , view
    )

import App.I18n.Keys as I18nKeys
import App.Messages as AppMsg exposing (..)
import App.Submodels.Context exposing (Context)
import App.Submodels.CotoSelection
import App.Submodels.LocalCotos exposing (LocalCotos)
import App.Types.Connection exposing (Connection, Direction(..), InboundConnection, Reordering(..))
import App.Types.Coto exposing (Coto, CotoId, Cotonoma, ElementId)
import App.Types.Graph exposing (Graph)
import App.Types.Session exposing (Session)
import App.Views.CotoToolbarMsg as CotoToolbarMsg exposing (Msg(..))
import Html exposing (..)
import Html.Attributes exposing (..)
import Set
import Utils.EventUtil exposing (onLinkButtonClick)
import Utils.HtmlUtil exposing (faIcon, materialIcon)
import Utils.UpdateUtil exposing (..)


view :
    Context context
    -> Session
    -> Maybe InboundConnection
    -> ElementId
    -> Coto
    -> Html AppMsg.Msg
view context session maybeInbound elementId coto =
    span [ class "coto-tool-buttons" ]
        [ connectButton context coto
        , maybeInbound
            |> Maybe.map (\inbound -> subCotoTools context session inbound elementId coto)
            |> Maybe.withDefault Utils.HtmlUtil.none
        , span [ class "default-buttons" ]
            [ if isSharedCotonoma coto then
                watchOrUnwatchButton context coto

              else
                pinButton context coto
            , editButton context session coto
            , addSubCotoButton context coto
            , selectButton context coto
            , openCotoMenuButton context coto
            ]
        ]


subCotoTools :
    Context context
    -> Session
    -> InboundConnection
    -> ElementId
    -> Coto
    -> Html AppMsg.Msg
subCotoTools context session inbound elementId coto =
    let
        buttons =
            [ editConnectionButton context session inbound coto
            , reorderButton context session inbound elementId coto
            ]
                |> List.filterMap identity

        buttonsWithBorder =
            if List.isEmpty buttons then
                []

            else
                buttons ++ [ span [ class "border" ] [] ]
    in
    span [ class "sub-coto-buttons" ] buttonsWithBorder


isReorderble : Context context -> Session -> InboundConnection -> Coto -> Bool
isReorderble context session inbound child =
    if inbound.siblings < 2 then
        False

    else if session.amishi.owner then
        True

    else
        inbound.parent
            |> Maybe.map
                (\parent ->
                    Just session.amishi.id
                        == (parent.amishi
                                |> Maybe.map (\amishi -> amishi.id)
                           )
                )
            |> Maybe.withDefault
                (context.cotonoma
                    |> Maybe.map
                        (\cotonoma ->
                            Just session.amishi.id
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
            && not (App.Submodels.CotoSelection.isSelected coto.id context)
    then
        span [ class "connecting-buttons" ]
            [ a
                [ class "tool-button connect"
                , title (context.i18nText I18nKeys.CotoToolbar_Connect)
                , onLinkButtonClick (AppMsg.OpenConnectModalByCoto coto)
                ]
                [ faIcon "link" Nothing ]
            , span [ class "border" ] []
            ]

    else
        Utils.HtmlUtil.none


pinButton : Context context -> Coto -> Html AppMsg.Msg
pinButton context coto =
    if
        not (App.Types.Graph.pinned coto.id context.graph)
            && (Just coto.id /= Maybe.map .cotoId context.cotonoma)
    then
        a
            [ class "tool-button pin-coto"
            , title (context.i18nText I18nKeys.CotoToolbar_Pin)
            , onLinkButtonClick (PinCoto coto.id)
            ]
            [ faIcon "thumb-tack" Nothing ]

    else
        Utils.HtmlUtil.none


isSharedCotonoma : Coto -> Bool
isSharedCotonoma coto =
    coto.asCotonoma
        |> Maybe.map (\cotonoma -> cotonoma.shared)
        |> Maybe.withDefault False


watchOrUnwatchButton : Context context -> Coto -> Html AppMsg.Msg
watchOrUnwatchButton context coto =
    coto.asCotonoma
        |> Maybe.map
            (\cotonoma ->
                if cotonoma.shared == True then
                    if App.Submodels.Context.isWatched cotonoma context then
                        unwatchButton context cotonoma

                    else
                        watchButton context cotonoma

                else
                    Utils.HtmlUtil.none
            )
        |> Maybe.withDefault Utils.HtmlUtil.none


watchButton : Context context -> Cotonoma -> Html AppMsg.Msg
watchButton context cotonoma =
    a
        [ classList
            [ ( "tool-button", True )
            , ( "watch", True )
            , ( "disabled", context.watchlistLoading )
            ]
        , title (context.i18nText I18nKeys.CotoMenuModal_Watch)
        , onLinkButtonClick
            (if context.watchlistLoading then
                AppMsg.NoOp

             else
                AppMsg.Watch cotonoma.key
            )
        ]
        [ materialIcon "visibility" Nothing ]


unwatchButton : Context context -> Cotonoma -> Html AppMsg.Msg
unwatchButton context cotonoma =
    a
        [ classList
            [ ( "tool-button", True )
            , ( "unwatch", True )
            , ( "disabled", context.watchlistLoading )
            ]
        , title (context.i18nText I18nKeys.CotoMenuModal_Unwatch)
        , onLinkButtonClick
            (if context.watchlistLoading then
                AppMsg.NoOp

             else
                AppMsg.Unwatch cotonoma.key
            )
        ]
        [ materialIcon "visibility_off" Nothing ]


editButton : Context context -> Session -> Coto -> Html AppMsg.Msg
editButton context session coto =
    if App.Types.Coto.checkWritePermission session coto then
        a
            [ class "tool-button edit-coto"
            , title (context.i18nText I18nKeys.CotoToolbar_Edit)
            , onLinkButtonClick (OpenEditorModal coto)
            ]
            [ materialIcon "edit" Nothing ]

    else
        Utils.HtmlUtil.none


addSubCotoButton : Context context -> Coto -> Html AppMsg.Msg
addSubCotoButton context coto =
    a
        [ class "tool-button add-coto"
        , title (context.i18nText I18nKeys.CotoToolbar_AddSubCoto)
        , onLinkButtonClick (OpenNewEditorModalWithSourceCoto coto)
        ]
        [ materialIcon "add" Nothing ]


selectButton : Context context -> Coto -> Html AppMsg.Msg
selectButton context coto =
    a
        [ class "tool-button select-coto"
        , title (context.i18nText I18nKeys.CotoToolbar_Select)
        , onLinkButtonClick (SelectCoto coto)
        ]
        [ materialIcon
            (if
                App.Submodels.CotoSelection.isSelected coto.id context
                    && not (Set.member coto.id context.deselecting)
             then
                "check_box"

             else
                "check_box_outline_blank"
            )
            Nothing
        ]


openCotoMenuButton : Context context -> Coto -> Html AppMsg.Msg
openCotoMenuButton context coto =
    a
        [ class "tool-button open-coto-menu"
        , title (context.i18nText I18nKeys.CotoToolbar_More)
        , onLinkButtonClick (AppMsg.OpenCotoMenuModal coto)
        ]
        [ materialIcon "more_horiz" Nothing ]


editConnectionButton :
    Context context
    -> Session
    -> InboundConnection
    -> Coto
    -> Maybe (Html AppMsg.Msg)
editConnectionButton context session inbound coto =
    inbound.parent
        |> Maybe.andThen
            (\parent ->
                if App.Types.Connection.canUpdate session parent inbound.connection then
                    a
                        [ class "tool-button"
                        , title (context.i18nText I18nKeys.CotoToolbar_EditConnection)
                        , onLinkButtonClick
                            (AppMsg.OpenConnectionModal inbound.connection parent coto)
                        ]
                        [ materialIcon "subdirectory_arrow_right" Nothing ]
                        |> Just

                else
                    Nothing
            )


reorderButton :
    Context context
    -> Session
    -> InboundConnection
    -> ElementId
    -> Coto
    -> Maybe (Html AppMsg.Msg)
reorderButton context session inbound elementId coto =
    if isReorderble context session inbound coto then
        a
            [ class "tool-button toggle-reorder-mode"
            , title (context.i18nText I18nKeys.CotoToolbar_Reorder)
            , onLinkButtonClick
                (SetReorderMode
                    (inbound.parentElementId
                        |> Maybe.map
                            (\parentElementId ->
                                SubCoto parentElementId elementId
                            )
                        |> Maybe.withDefault (PinnedCoto elementId)
                    )
                )
            ]
            [ faIcon "sort" Nothing ]
            |> Just

    else
        Nothing


type alias UpdateModel model =
    LocalCotos model


update : Context context -> CotoToolbarMsg.Msg -> UpdateModel model -> ( UpdateModel model, Cmd AppMsg.Msg )
update context msg model =
    case msg of
        Init ->
            model |> withoutCmd
