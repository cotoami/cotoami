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
    }


initModel : Coto -> Model
initModel coto =
    { coto = coto
    , cotonomaStats = Nothing
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
    , content = div [] (menuItems context session graph model)
    , buttons = []
    }


checkWritePermission : Session -> Model -> Bool
checkWritePermission session model =
    (Maybe.map (\amishi -> amishi.id) model.coto.amishi) == (Just session.id)


menuItems : Context -> Session -> Graph -> Model -> List (Html Msg)
menuItems context session graph model =
    let
        cotonomaNotDeletable =
            model.cotonomaStats
                |> Maybe.map (\stats -> not (isCotonomaEmpty stats))
                |> Maybe.withDefault model.coto.asCotonoma
    in
        [ div
            [ class "menu-item"
            , onLinkButtonClick (OpenTraversal model.coto.id)
            ]
            [ a
                [ class "explore" ]
                [ faIcon "sitemap" Nothing
                , span [ class "menu-title" ]
                    [ text "Explore the connections" ]
                ]
            ]
        , if App.Types.Graph.pinned model.coto.id graph then
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
        , if checkWritePermission session model then
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
        , if checkWritePermission session model then
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
