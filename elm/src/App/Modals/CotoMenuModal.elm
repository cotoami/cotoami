module App.Modals.CotoMenuModal exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Util.Modal as Modal
import Util.HtmlUtil exposing (faIcon, materialIcon)
import Util.EventUtil exposing (onLinkButtonClick)
import App.Types.Coto exposing (Coto)
import App.Model exposing (Model)
import App.Messages exposing (Msg(..))


view : Model -> Html Msg
view model =
    model.cotoMenu
        |> Maybe.map (\coto -> modalConfig coto model)
        |> Modal.view "coto-menu-modal"


modalConfig : Coto -> Model -> Modal.Config Msg
modalConfig coto model =
    { closeMessage = CloseModal
    , title = text ""
    , content =
        div []
            [ div
                [ class "menu-item"
                , onLinkButtonClick (OpenTraversal coto.id)
                ]
                [ a
                    [ class "explore", title "Explore" ]
                    [ faIcon "sitemap" Nothing
                    , span [ class "menu-title" ]
                        [ text "Explore the connections" ]
                    ]
                ]
            , div
                [ class "menu-item"
                , onLinkButtonClick (ConfirmDeleteCoto coto)
                ]
                [ a
                    [ class "delete", title "Delete" ]
                    [ materialIcon "delete" Nothing
                    , span [ class "menu-title" ]
                        [ text "Delete" ]
                    ]
                ]
            ]
    , buttons = []
    }
