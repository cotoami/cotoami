module App.Modals.CotoMenuModal exposing (Model, initModel, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Util.Modal as Modal
import Util.HtmlUtil exposing (faIcon, materialIcon)
import Util.EventUtil exposing (onLinkButtonClick)
import App.Types.Coto exposing (Coto, CotonomaStats)
import App.Types.Session exposing (Session)
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


view : Maybe Session -> Maybe Model -> Html Msg
view maybeSession maybeModel =
    (Maybe.map2
        (\session model -> modalConfig session model)
        maybeSession
        maybeModel
    )
        |> Modal.view "coto-menu-modal"


modalConfig : Session -> Model -> Modal.Config Msg
modalConfig session model =
    { closeMessage = CloseModal
    , title = text ""
    , content = div [] (menuItems session model)
    , buttons = []
    }


checkWritePermission : Session -> Model -> Bool
checkWritePermission session model =
    (Maybe.map (\amishi -> amishi.id) model.coto.amishi) == (Just session.id)


menuItems : Session -> Model -> List (Html Msg)
menuItems session model =
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
