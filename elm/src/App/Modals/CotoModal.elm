module App.Modals.CotoModal exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Util.Modal as Modal
import App.Types.Coto exposing (Coto)
import App.Markdown
import App.Messages exposing (Msg(..))


view : Maybe Coto -> Html Msg
view maybeCoto =
    Modal.view
        "coto-modal"
        (case maybeCoto of
            Nothing ->
                Nothing

            Just coto ->
                Just (modalConfig coto)
        )


modalConfig : Coto -> Modal.Config Msg
modalConfig coto =
    { closeMessage = CloseModal
    , title =
        if coto.asCotonoma then
            "Cotonoma"
        else
            "Coto"
    , content =
        div []
            [ div [ class "coto-content" ]
                [ App.Markdown.markdown coto.content
                ]
            ]
    , buttons =
        [ if coto.asCotonoma then
            span [] []
          else
            button [ class "button", onClick ConfirmDeleteCoto ] [ text "Delete" ]
        ]
    }
