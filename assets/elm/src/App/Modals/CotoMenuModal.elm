module App.Modals.CotoMenuModal exposing (Model, initModel, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Exts.Maybe exposing (isJust, isNothing)
import Util.Modal as Modal
import Util.HtmlUtil exposing (faIcon, materialIcon)
import Util.EventUtil exposing (onLinkButtonClick)
import App.Types.Coto exposing (Coto, Cotonoma, CotonomaStats)
import App.Types.Session exposing (Session)
import App.Types.Context exposing (Context)
import App.Types.Graph exposing (Graph)
import App.Messages exposing (Msg(..))


type alias Model =
    { coto : Coto
    , cotonomaStats : Maybe CotonomaStats
    , cotonomaPinned : Bool
    }


initModel : Bool -> Coto -> Model
initModel cotonomaPinned coto =
    { coto = coto
    , cotonomaStats = Nothing
    , cotonomaPinned = cotonomaPinned
    }


isCotonomaEmpty : CotonomaStats -> Bool
isCotonomaEmpty stats =
    stats.cotos == 0 && stats.connections == 0


view : Context -> Graph -> Maybe Model -> Html Msg
view context graph maybeModel =
    (Maybe.map2
        (\session model -> modalConfig context session graph model)
        context.session
        maybeModel
    )
        |> Modal.view "coto-menu-modal"


modalConfig : Context -> Session -> Graph -> Model -> Modal.Config Msg
modalConfig context session graph model =
    { closeMessage = CloseModal
    , title = text ""
    , content =
        [ [ menuItemInfo model
          , menuItemExplore model
          ]
        , if App.Types.Context.atHome context then
            [ menuItemPinUnpin context graph model ]
          else
            [ menuItemPinCotoToMyHome context graph model
            , menuItemPinUnpin context graph model
            ]
        , [ menuItemPinUnpinCotonoma session model
          , menuItemEdit session model
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


menuItemInfo : Model -> Html Msg
menuItemInfo model =
    div
        [ class "menu-item"
        , onLinkButtonClick (OpenCotoModal model.coto)
        ]
        [ a
            [ class "info" ]
            [ materialIcon "info" Nothing
            , span [ class "menu-title" ] [ text "Info" ]
            ]
        ]


menuItemExplore : Model -> Html Msg
menuItemExplore model =
    div
        [ class "menu-item"
        , onLinkButtonClick (OpenTraversal model.coto.id)
        ]
        [ a
            [ class "explore" ]
            [ faIcon "sitemap" Nothing
            , span [ class "menu-title" ] [ text "Explore the connections" ]
            ]
        ]


menuItemPinUnpin : Context -> Graph -> Model -> Html Msg
menuItemPinUnpin context graph model =
    if App.Types.Graph.pinned model.coto.id graph then
        div
            [ class "menu-item"
            , onLinkButtonClick (UnpinCoto model.coto.id)
            ]
            [ a
                [ class "unpin" ]
                [ faIcon "thumb-tack" Nothing
                , faIcon "remove" Nothing
                , pinOrUnpinMenuTitle context.cotonoma False
                ]
            ]
    else
        div
            [ class "menu-item"
            , onLinkButtonClick (PinCoto model.coto.id)
            ]
            [ a
                [ class "pin" ]
                [ faIcon "thumb-tack" Nothing
                , pinOrUnpinMenuTitle context.cotonoma True
                ]
            ]


menuItemPinCotoToMyHome : Context -> Graph -> Model -> Html Msg
menuItemPinCotoToMyHome context graph model =
    div
        [ class "menu-item"
        , onLinkButtonClick (PinCotoToMyHome model.coto.id)
        ]
        [ a
            [ class "pin-to-my-home" ]
            [ faIcon "thumb-tack" Nothing
            , pinOrUnpinMenuTitle Nothing True
            ]
        ]


pinOrUnpinMenuTitle : Maybe Cotonoma -> Bool -> Html Msg
pinOrUnpinMenuTitle maybeCotonoma pinOrUnpin =
    let
        prefix =
            if pinOrUnpin then
                "Pin to "
            else
                "Unpin from "
    in
        span [ class "menu-title" ]
            (maybeCotonoma
                |> Maybe.map
                    (\cotonoma ->
                        [ text prefix
                        , span [ class "cotonoma" ] [ text cotonoma.name ]
                        ]
                    )
                |> Maybe.withDefault [ text (prefix ++ "My Home") ]
            )


menuItemPinUnpinCotonoma : Session -> Model -> Html Msg
menuItemPinUnpinCotonoma session model =
    if session.owner then
        model.coto.asCotonoma
            |> Maybe.map
                (\cotonoma ->
                    div
                        [ class "menu-item"
                        , onLinkButtonClick
                            (PinOrUnpinCotonoma
                                cotonoma.key
                                (not model.cotonomaPinned)
                            )
                        ]
                        [ if model.cotonomaPinned then
                            a
                                [ class "unpin-cotonoma" ]
                                [ faIcon "thumb-tack" Nothing
                                , faIcon "remove" Nothing
                                , span [ class "menu-title" ]
                                    [ text "Unpin from the main nav" ]
                                ]
                          else
                            a
                                [ class "pin-cotonoma" ]
                                [ faIcon "thumb-tack" Nothing
                                , span [ class "menu-title" ]
                                    [ text "Pin to the main nav" ]
                                ]
                        ]
                )
            |> Maybe.withDefault Util.HtmlUtil.none
    else
        Util.HtmlUtil.none


menuItemEdit : Session -> Model -> Html Msg
menuItemEdit session model =
    if checkWritePermission session model then
        div
            [ class "menu-item"
            , onLinkButtonClick (OpenEditorModal model.coto)
            ]
            [ a
                [ class "edit" ]
                [ materialIcon "edit" Nothing
                , span [ class "menu-title" ] [ text "Edit" ]
                ]
            ]
    else
        Util.HtmlUtil.none


menuItemAddCoto : Model -> Html Msg
menuItemAddCoto model =
    div
        [ class "menu-item"
        , onLinkButtonClick (OpenNewEditorModalWithSourceCoto model.coto)
        ]
        [ a
            [ class "add-coto" ]
            [ materialIcon "add" Nothing
            , span [ class "menu-title" ] [ text "Create a connected Coto" ]
            ]
        ]


menuItemCotonomatize : Session -> Model -> Html Msg
menuItemCotonomatize session model =
    if (isNothing model.coto.asCotonoma) && (checkWritePermission session model) then
        div
            [ class "menu-item"
            , onLinkButtonClick (ConfirmCotonomatize model.coto)
            ]
            [ a
                [ class "cotonomatize" ]
                [ faIcon "users" Nothing
                , span [ class "menu-title" ]
                    [ text "Promote to a Cotonoma" ]
                ]
            ]
    else
        Util.HtmlUtil.none


menuItemDelete : Session -> Model -> Html Msg
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
                    , onLinkButtonClick (ConfirmDeleteCoto model.coto)
                    ]
                    [ a
                        [ class "delete" ]
                        [ materialIcon "delete" Nothing
                        , span [ class "menu-title" ] [ text "Delete" ]
                        ]
                    ]
        else
            Util.HtmlUtil.none
