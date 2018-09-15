module App.Modals.CotoMenuModal
    exposing
        ( Model
        , initModel
        , WithCotoMenuModal
        , open
        , update
        , view
        )

import Html exposing (..)
import Html.Attributes exposing (..)
import Exts.Maybe exposing (isJust, isNothing)
import Utils.Modal as Modal
import Utils.HtmlUtil exposing (faIcon, materialIcon)
import Utils.EventUtil exposing (onLinkButtonClick)
import Utils.UpdateUtil exposing (..)
import App.I18n.Keys as I18nKeys
import App.Types.Coto exposing (Coto, Cotonoma, CotonomaStats)
import App.Types.Session exposing (Session)
import App.Types.Graph exposing (Graph)
import App.Submodels.Context exposing (Context)
import App.Submodels.Modals exposing (Modal(CotoMenuModal), Modals)
import App.Messages as AppMsg
import App.Commands
import App.Server.Cotonoma
import App.Modals.CotoMenuModalMsg as CotoMenuModalMsg exposing (Msg(..))


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


type alias WithCotoMenuModal model =
    { model | cotoMenuModal : Maybe Model }


open : Coto -> Modals (WithCotoMenuModal model) -> ( Modals (WithCotoMenuModal model), Cmd AppMsg.Msg )
open coto model =
    { model | cotoMenuModal = Just (initModel coto) }
        |> App.Submodels.Modals.openModal CotoMenuModal
        |> withCmd (\_ -> App.Commands.sendMsg (AppMsg.CotoMenuModalMsg Init))


update : Context context -> CotoMenuModalMsg.Msg -> Model -> ( Model, Cmd AppMsg.Msg )
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


view : Context context -> Graph -> Maybe Model -> Html AppMsg.Msg
view context graph maybeModel =
    (Maybe.map2
        (\session model -> modalConfig context session graph model)
        context.session
        maybeModel
    )
        |> Modal.view "coto-menu-modal"


modalConfig : Context context -> Session -> Graph -> Model -> Modal.Config AppMsg.Msg
modalConfig context session graph model =
    { closeMessage = AppMsg.CloseModal
    , title = text ""
    , content =
        [ [ menuItemInfo context model
          , menuItemExplore context model
          ]
        , if App.Submodels.Context.atHome context then
            [ menuItemPinUnpin context graph model ]
          else
            [ menuItemPinCotoToMyHome context graph model
            , menuItemPinUnpin context graph model
            ]
        , [ menuItemEdit session model
          , menuItemAddCoto model
          , menuItemCotonomatize session model
          , menuItemDelete session model
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
    div
        [ class "menu-item"
        , onLinkButtonClick (AppMsg.OpenCotoModal model.coto)
        ]
        [ a
            [ class "info" ]
            [ materialIcon "info" Nothing
            , span [ class "menu-title" ]
                [ text (context.i18nText I18nKeys.CotoMenuModal_Info) ]
            ]
        ]


menuItemExplore : Context context -> Model -> Html AppMsg.Msg
menuItemExplore context model =
    div
        [ class "menu-item"
        , onLinkButtonClick (AppMsg.OpenTraversal model.coto.id)
        ]
        [ a
            [ class "explore" ]
            [ faIcon "sitemap" Nothing
            , span [ class "menu-title" ]
                [ text (context.i18nText I18nKeys.CotoMenuModal_ExploreConnections) ]
            ]
        ]


menuItemPinUnpin : Context context -> Graph -> Model -> Html AppMsg.Msg
menuItemPinUnpin context graph model =
    if App.Types.Graph.pinned model.coto.id graph then
        div
            [ class "menu-item"
            , onLinkButtonClick (AppMsg.UnpinCoto model.coto.id)
            ]
            [ a
                [ class "unpin" ]
                [ faIcon "thumb-tack" Nothing
                , faIcon "remove" Nothing
                , pinOrUnpinMenuTitle context context.cotonoma False
                ]
            ]
    else
        div
            [ class "menu-item"
            , onLinkButtonClick (AppMsg.PinCoto model.coto.id)
            ]
            [ a
                [ class "pin" ]
                [ faIcon "thumb-tack" Nothing
                , pinOrUnpinMenuTitle context context.cotonoma True
                ]
            ]


menuItemPinCotoToMyHome : Context context -> Graph -> Model -> Html AppMsg.Msg
menuItemPinCotoToMyHome context graph model =
    div
        [ class "menu-item"
        , onLinkButtonClick (AppMsg.PinCotoToMyHome model.coto.id)
        ]
        [ a
            [ class "pin-to-my-home" ]
            [ faIcon "thumb-tack" Nothing
            , pinOrUnpinMenuTitle context Nothing True
            ]
        ]


pinOrUnpinMenuTitle : Context context -> Maybe Cotonoma -> Bool -> Html AppMsg.Msg
pinOrUnpinMenuTitle context maybeCotonoma pinOrUnpin =
    let
        prefix =
            if pinOrUnpin then
                context.i18nText I18nKeys.CotoMenuModal_PinTo
            else
                context.i18nText I18nKeys.CotoMenuModal_UnpinFrom
    in
        span [ class "menu-title" ]
            (maybeCotonoma
                |> Maybe.map
                    (\cotonoma ->
                        [ text prefix
                        , span [ class "cotonoma" ] [ text cotonoma.name ]
                        ]
                    )
                |> Maybe.withDefault
                    [ text
                        (prefix
                            ++ " "
                            ++ (context.i18nText I18nKeys.MyHome)
                        )
                    ]
            )


menuItemEdit : Session -> Model -> Html AppMsg.Msg
menuItemEdit session model =
    if checkWritePermission session model then
        div
            [ class "menu-item"
            , onLinkButtonClick (AppMsg.OpenEditorModal model.coto)
            ]
            [ a
                [ class "edit" ]
                [ materialIcon "edit" Nothing
                , span [ class "menu-title" ] [ text "Edit" ]
                ]
            ]
    else
        Utils.HtmlUtil.none


menuItemAddCoto : Model -> Html AppMsg.Msg
menuItemAddCoto model =
    div
        [ class "menu-item"
        , onLinkButtonClick (AppMsg.OpenNewEditorModalWithSourceCoto model.coto)
        ]
        [ a
            [ class "add-coto" ]
            [ materialIcon "add" Nothing
            , span [ class "menu-title" ] [ text "Create a connected Coto" ]
            ]
        ]


menuItemCotonomatize : Session -> Model -> Html AppMsg.Msg
menuItemCotonomatize session model =
    if (isNothing model.coto.asCotonoma) && (checkWritePermission session model) then
        div
            [ class "menu-item"
            , onLinkButtonClick (AppMsg.ConfirmCotonomatize model.coto)
            ]
            [ a
                [ class "cotonomatize" ]
                [ faIcon "users" Nothing
                , span [ class "menu-title" ]
                    [ text "Promote to a Cotonoma" ]
                ]
            ]
    else
        Utils.HtmlUtil.none


menuItemDelete : Session -> Model -> Html AppMsg.Msg
menuItemDelete session model =
    let
        nonEmptyCotonoma =
            model.cotonomaStats
                |> Maybe.map (\stats -> not (isCotonomaEmpty stats))
                |> Maybe.withDefault (isJust model.coto.asCotonoma)
    in
        if checkWritePermission session model then
            if nonEmptyCotonoma then
                div [ class "menu-item disabled" ]
                    [ span
                        [ class "delete" ]
                        [ materialIcon "delete" Nothing
                        , span [ class "menu-title" ] [ text "Delete" ]
                        ]
                    ]
            else
                div
                    [ class "menu-item"
                    , onLinkButtonClick (AppMsg.ConfirmDeleteCoto model.coto)
                    ]
                    [ a
                        [ class "delete" ]
                        [ materialIcon "delete" Nothing
                        , span [ class "menu-title" ] [ text "Delete" ]
                        ]
                    ]
        else
            Utils.HtmlUtil.none
