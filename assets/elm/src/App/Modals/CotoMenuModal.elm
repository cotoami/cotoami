module App.Modals.CotoMenuModal exposing
    ( Model
    , initModel
    , sendInit
    , update
    , view
    )

import App.Commands
import App.I18n.Keys as I18nKeys
import App.Messages as AppMsg
import App.Modals.CotoMenuModalMsg as ModalMsg exposing (Msg(..))
import App.Server.Cotonoma
import App.Submodels.Context exposing (Context)
import App.Types.Coto exposing (Coto, Cotonoma, CotonomaStats)
import App.Types.Graph exposing (Graph)
import App.Types.Session exposing (Session)
import Exts.Maybe exposing (isJust, isNothing)
import Html exposing (..)
import Html.Attributes exposing (..)
import Utils.EventUtil exposing (onLinkButtonClick)
import Utils.HtmlUtil exposing (faIcon, materialIcon)
import Utils.Modal
import Utils.UpdateUtil exposing (..)


type alias Model =
    { coto : Coto
    , cotonomaStats : Maybe CotonomaStats
    }


initModel : Coto -> Model
initModel coto =
    { coto = coto
    , cotonomaStats = Nothing
    }


isCotonomaEmpty : CotonomaStats -> Bool
isCotonomaEmpty stats =
    stats.cotos == 0 && stats.connections == 0


view : Context context -> Session -> Model -> Html AppMsg.Msg
view context session model =
    model
        |> modalConfig context session
        |> Utils.Modal.view "coto-menu-modal"


modalConfig : Context context -> Session -> Model -> Utils.Modal.Config AppMsg.Msg
modalConfig context session model =
    { closeMessage = AppMsg.CloseModal
    , title = text ""
    , content =
        [ [ menuItemInfo context model
          , menuItemExplore context model
          , menuItemWatchOrUnwatch context model
          ]
        , if App.Submodels.Context.atHome context then
            [ menuItemPinUnpin context context.graph model ]

          else
            [ menuItemPinCotoToMyHome context context.graph model
            , menuItemPinUnpin context context.graph model
            ]
        , [ menuItemEdit context session model
          , menuItemAddCoto context model
          , menuItemCotonomatize context session model
          , menuItemDelete context session model
          ]
        ]
            |> List.concat
            |> div []
    , buttons = []
    }


checkWritePermission : Session -> Model -> Bool
checkWritePermission session model =
    App.Types.Coto.checkWritePermission session model.coto


menuItemInfo : Context context -> Model -> Html AppMsg.Msg
menuItemInfo context model =
    menuItem
        False
        "info"
        [ materialIcon "info" Nothing
        , span [ class "menu-title" ]
            [ text (context.i18nText I18nKeys.CotoMenuModal_Info) ]
        ]
        (AppMsg.OpenCotoModal model.coto)


menuItemExplore : Context context -> Model -> Html AppMsg.Msg
menuItemExplore context model =
    menuItem
        False
        "explore"
        [ faIcon "sitemap" Nothing
        , span [ class "menu-title" ]
            [ text (context.i18nText I18nKeys.CotoMenuModal_ExploreConnections) ]
        ]
        (AppMsg.OpenTraversal model.coto.id)


menuItemPinUnpin : Context context -> Graph -> Model -> Html AppMsg.Msg
menuItemPinUnpin context graph model =
    if App.Types.Graph.pinned model.coto.id graph then
        menuItem
            False
            "unpin"
            [ faIcon "thumb-tack" Nothing
            , faIcon "remove" Nothing
            , span [ class "menu-title" ]
                [ text (pinOrUnpinMenuTitle context False) ]
            ]
            (AppMsg.UnpinCoto model.coto.id)

    else
        menuItem
            False
            "pin"
            [ faIcon "thumb-tack" Nothing
            , span [ class "menu-title" ]
                [ text (pinOrUnpinMenuTitle context True) ]
            ]
            (AppMsg.PinCoto model.coto.id)


menuItemPinCotoToMyHome : Context context -> Graph -> Model -> Html AppMsg.Msg
menuItemPinCotoToMyHome context graph model =
    menuItem
        False
        "pin-to-my-home"
        [ faIcon "thumb-tack" Nothing
        , span [ class "menu-title" ]
            [ text (context.i18nText I18nKeys.CotoMenuModal_PinToMyHome) ]
        ]
        (AppMsg.PinCotoToMyHome model.coto.id)


pinOrUnpinMenuTitle : Context context -> Bool -> String
pinOrUnpinMenuTitle context pinOrUnpin =
    if isJust context.cotonoma then
        if pinOrUnpin then
            context.i18nText I18nKeys.CotoMenuModal_PinToCotonoma

        else
            context.i18nText I18nKeys.CotoMenuModal_UnpinFromCotonoma

    else if pinOrUnpin then
        context.i18nText I18nKeys.CotoMenuModal_PinToMyHome

    else
        context.i18nText I18nKeys.CotoMenuModal_UnpinFromMyHome


menuItemEdit : Context context -> Session -> Model -> Html AppMsg.Msg
menuItemEdit context session model =
    if checkWritePermission session model then
        menuItem
            False
            "edit"
            [ materialIcon "edit" Nothing
            , span [ class "menu-title" ]
                [ text (context.i18nText I18nKeys.CotoMenuModal_Edit) ]
            ]
            (AppMsg.OpenEditorModal model.coto)

    else
        Utils.HtmlUtil.none


menuItemAddCoto : Context context -> Model -> Html AppMsg.Msg
menuItemAddCoto context model =
    menuItem
        False
        "add-coto"
        [ materialIcon "add" Nothing
        , span [ class "menu-title" ]
            [ text (context.i18nText I18nKeys.CotoMenuModal_AddSubCoto) ]
        ]
        (AppMsg.OpenNewEditorModalWithSourceCoto model.coto)


menuItemCotonomatize : Context context -> Session -> Model -> Html AppMsg.Msg
menuItemCotonomatize context session model =
    if isNothing model.coto.asCotonoma && checkWritePermission session model then
        menuItem
            False
            "cotonomatize"
            [ faIcon "users" Nothing
            , span [ class "menu-title" ]
                [ text (context.i18nText I18nKeys.CotoMenuModal_Cotonomatize) ]
            ]
            (AppMsg.ConfirmCotonomatize model.coto)

    else
        Utils.HtmlUtil.none


menuItemWatchOrUnwatch : Context context -> Model -> Html AppMsg.Msg
menuItemWatchOrUnwatch context model =
    model.coto.asCotonoma
        |> Maybe.map
            (\cotonoma ->
                if cotonoma.shared == True then
                    if App.Submodels.Context.isWatched cotonoma context then
                        menuItemUnwatch context cotonoma

                    else
                        menuItemWatch context cotonoma

                else
                    Utils.HtmlUtil.none
            )
        |> Maybe.withDefault Utils.HtmlUtil.none


menuItemWatch : Context context -> Cotonoma -> Html AppMsg.Msg
menuItemWatch context cotonoma =
    menuItem
        context.watchlistLoading
        "watch"
        [ materialIcon "visibility" Nothing
        , span [ class "menu-title" ]
            [ text (context.i18nText I18nKeys.CotoMenuModal_Watch) ]
        ]
        (AppMsg.Watch cotonoma.key)


menuItemUnwatch : Context context -> Cotonoma -> Html AppMsg.Msg
menuItemUnwatch context cotonoma =
    menuItem
        context.watchlistLoading
        "unwatch"
        [ materialIcon "visibility_off" Nothing
        , span [ class "menu-title" ]
            [ text (context.i18nText I18nKeys.CotoMenuModal_Unwatch) ]
        ]
        (AppMsg.Unwatch cotonoma.key)


menuItemDelete : Context context -> Session -> Model -> Html AppMsg.Msg
menuItemDelete context session model =
    let
        nonEmptyCotonoma =
            model.cotonomaStats
                |> Maybe.map (\stats -> not (isCotonomaEmpty stats))
                |> Maybe.withDefault (isJust model.coto.asCotonoma)
    in
    if checkWritePermission session model then
        menuItem
            nonEmptyCotonoma
            "delete"
            [ materialIcon "delete" Nothing
            , span [ class "menu-title" ]
                [ text (context.i18nText I18nKeys.CotoMenuModal_Delete) ]
            ]
            (AppMsg.ConfirmDeleteCoto model.coto.id)

    else
        Utils.HtmlUtil.none


menuItem :
    Bool
    -> String
    -> List (Html AppMsg.Msg)
    -> AppMsg.Msg
    -> Html AppMsg.Msg
menuItem disabled cssClass label msg =
    if disabled then
        div [ class "menu-item disabled" ]
            [ span [ class cssClass ] label ]

    else
        div
            [ class "menu-item"
            , onLinkButtonClick msg
            ]
            [ a [ class cssClass ] label ]


update : Context context -> ModalMsg.Msg -> Model -> ( Model, Cmd AppMsg.Msg )
update context msg model =
    case msg of
        Init ->
            ( model
            , model.coto.asCotonoma
                |> Maybe.map
                    (\cotonoma ->
                        App.Server.Cotonoma.fetchStats
                            (AppMsg.CotoMenuModalMsg << CotonomaStatsFetched)
                            cotonoma.key
                    )
                |> Maybe.withDefault Cmd.none
            )

        CotonomaStatsFetched (Ok stats) ->
            { model | cotonomaStats = Just stats }
                |> withoutCmd

        CotonomaStatsFetched (Err _) ->
            model |> withoutCmd


sendInit : Cmd AppMsg.Msg
sendInit =
    ModalMsg.Init
        |> AppMsg.CotoMenuModalMsg
        |> App.Commands.sendMsg
