module App.Modals.CotoModal exposing (Model, initModel, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Util.Modal as Modal
import App.Types.Coto exposing (Coto)
import App.Markdown
import App.Messages exposing (Msg(..))


type alias Model =
    { coto : Coto
    }


initModel : Coto -> Model
initModel coto =
    { coto = coto
    }


view : Maybe Model -> Html Msg
view maybeModel =
    maybeModel
        |> Maybe.map modalConfig
        |> Modal.view "coto-modal"


modalConfig : Model -> Modal.Config Msg
modalConfig model =
    { closeMessage = CloseModal
    , title =
        if model.coto.asCotonoma then
            "Cotonoma"
        else
            "Coto"
    , content =
        div []
            [ div [ class "coto-content" ]
                [ App.Markdown.markdown model.coto.content
                ]
            ]
    , buttons =
        [ button
            [ class "button" ]
            [ text "Edit" ]
        , if model.coto.asCotonoma then
            span [] []
          else
            button
                [ class "button", onClick ConfirmDeleteCoto ]
                [ text "Delete" ]
        ]
    }
