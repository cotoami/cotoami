module App.Modals.CotoMenuModal exposing (Model, initModel, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Util.Modal as Modal
import Util.HtmlUtil exposing (faIcon, materialIcon)
import Util.EventUtil exposing (onLinkButtonClick)
import App.Types.Coto exposing (Coto, CotonomaStats)
import App.Types.Session exposing (Session)
import App.Types.Context exposing (Context)
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


view : Context -> Maybe Model -> Html Msg
view context maybeModel =
    (Maybe.map2
        (\session model -> modalConfig context session model)
        context.session
        maybeModel
    )
        |> Modal.view "coto-menu-modal"


modalConfig : Context -> Session -> Model -> Modal.Config Msg
modalConfig context session model =
    { closeMessage = CloseModal
    , title = text ""
    , content = div [] (menuItems context session model)
    , buttons = []
    }


checkWritePermission : Session -> Model -> Bool
checkWritePermission session model =
    (Maybe.map (\amishi -> amishi.id) model.coto.amishi) == (Just session.id)


menuItems : Context -> Session -> Model -> List (Html Msg)
menuItems context session model =
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
