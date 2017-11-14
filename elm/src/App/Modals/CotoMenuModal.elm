module App.Modals.CotoMenuModal exposing (Model, initModel, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Util.Modal as Modal
import Util.HtmlUtil exposing (faIcon, materialIcon)
import Util.EventUtil exposing (onLinkButtonClick)
import App.Types.Coto exposing (Coto, CotonomaStats)
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
        div []
            [ menuItemInfo model
            , menuItemExplore model
            , menuItemPinUnpin context graph model
            , menuItemPinUnpinCotonoma session model
            , menuItemEdit session model
            , menuItemCotonomatize session model
            , menuItemDelete session model
            ]
    , buttons = []
    }


checkWritePermission : Session -> Model -> Bool
checkWritePermission session model =
    (Maybe.map (\amishi -> amishi.id) model.coto.amishi) == (Just session.id)


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
                , pinOrUnpinMenuTitle context False
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
                , pinOrUnpinMenuTitle context True
                ]
            ]


pinOrUnpinMenuTitle : Context -> Bool -> Html Msg
pinOrUnpinMenuTitle context pinOrUnpin =
    let
        prefix =
            if pinOrUnpin then
                "Pin to "
            else
                "Unpin from "
    in
        span [ class "menu-title" ]
            (context.cotonoma
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
        model.coto.cotonomaKey
            |> Maybe.map
                (\cotonomaKey ->
                    div
                        [ class "menu-item"
                        , onLinkButtonClick
                            (PinOrUnpinCotonoma
                                cotonomaKey
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
            |> Maybe.withDefault (div [] [])
    else
        div [] []


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
        div [] []


menuItemCotonomatize : Session -> Model -> Html Msg
menuItemCotonomatize session model =
    if (not model.coto.asCotonoma) && (checkWritePermission session model) then
        div
            [ class "menu-item"
            , onLinkButtonClick (ConfirmCotonomatize model.coto)
            ]
            [ a
                [ class "cotonomatize" ]
                [ faIcon "users" Nothing
                , span [ class "menu-title" ]
                    [ text "Convert into a Cotonoma" ]
                ]
            ]
    else
        div [] []


menuItemDelete : Session -> Model -> Html Msg
menuItemDelete session model =
    let
        cotonomaNotDeletable =
            model.cotonomaStats
                |> Maybe.map (\stats -> not (isCotonomaEmpty stats))
                |> Maybe.withDefault model.coto.asCotonoma
    in
        if checkWritePermission session model then
            if cotonomaNotDeletable then
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
            div [] []
