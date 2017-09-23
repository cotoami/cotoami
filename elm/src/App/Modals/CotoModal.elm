module App.Modals.CotoModal exposing (Model, initModel, update, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Util.Modal as Modal
import App.Types.Coto exposing (Coto, updateContent)
import App.Markdown
import App.Messages as AppMsg exposing (Msg(CloseModal, ConfirmDeleteCoto))
import App.Modals.CotoModalMsg as CotoModalMsg exposing (Msg(..))


type alias Model =
    { coto : Coto
    , editing : Bool
    , editingContent : String
    }


initModel : Coto -> Model
initModel coto =
    { coto = coto
    , editing = False
    , editingContent = coto.content
    }


update : CotoModalMsg.Msg -> Model -> ( Model, Cmd CotoModalMsg.Msg )
update msg model =
    case msg of
        Edit ->
            { model | editing = True } ! []

        EditorInput content ->
            { model | editingContent = content } ! []

        Save ->
            { model
                | coto = updateContent model.editingContent model.coto
                , editing = False
            } ! []


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
            [ if model.editing then
                div [ class "coto-editor" ]
                    [ textarea
                        [ class "coto"
                        , value model.editingContent
                        , onInput (AppMsg.CotoModalMsg << EditorInput)
                        ]
                        []
                    ]
              else
                div [ class "coto-content" ]
                    [ App.Markdown.markdown model.coto.content ]
            ]
    , buttons =
        [ if model.editing then
            button
                [ class "button button-primary", onClick (AppMsg.CotoModalMsg Save) ]
                [ text "Save" ]
          else
            button
                [ class "button", onClick (AppMsg.CotoModalMsg Edit) ]
                [ text "Edit" ]
        , if model.coto.asCotonoma then
            span [] []
          else
            button
                [ class "button", onClick ConfirmDeleteCoto ]
                [ text "Delete" ]
        ]
    }
