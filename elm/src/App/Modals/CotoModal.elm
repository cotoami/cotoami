module App.Modals.CotoModal exposing (Model, initModel, update, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Util.Modal as Modal
import App.Types.Coto exposing (Coto)
import App.Markdown
import App.Messages as AppMsg exposing (Msg(CloseModal, ConfirmDeleteCoto))
import App.Modals.CotoModalMsg as CotoModalMsg exposing (Msg(..))


type alias Model =
    { coto : Coto
    , editing : Bool
    }


initModel : Coto -> Model
initModel coto =
    { coto = coto
    , editing = False
    }


update : CotoModalMsg.Msg -> Model -> ( Model, Cmd CotoModalMsg.Msg )
update msg model =
    case msg of
        ToggleEditing ->
            { model | editing = not model.editing } ! []


view : Maybe Model -> Html AppMsg.Msg
view maybeModel =
    maybeModel
        |> Maybe.map modalConfig
        |> Modal.view "coto-modal"


modalConfig : Model -> Modal.Config AppMsg.Msg
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
