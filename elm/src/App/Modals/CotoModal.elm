module App.Modals.CotoModal exposing (Model, initModel, update, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Util.Modal as Modal
import App.Types.Coto exposing (Coto, updateContent, cotonomaNameMaxlength)
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

        CancelEditing ->
            { model
                | editing = False
                , editingContent = model.coto.content
            }
                ! []

        Save ->
            { model
                | editing = False
                , coto = updateContent model.editingContent model.coto
            }
                ! []


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
                    [ if model.coto.asCotonoma then
                        input
                            [ type_ "text"
                            , class "u-full-width"
                            , placeholder "Cotonoma name"
                            , maxlength cotonomaNameMaxlength
                            , value model.editingContent
                            , onInput (AppMsg.CotoModalMsg << EditorInput)
                            ]
                            []
                      else
                        textarea
                            [ class "coto"
                            , value model.editingContent
                            , onInput (AppMsg.CotoModalMsg << EditorInput)
                            ]
                            []
                    ]
              else
                if model.coto.asCotonoma then
                    div [ class "cotonoma" ]
                        [ i [ class "material-icons" ] [ text "exit_to_app" ]
                        , span [ class "cotonoma-name" ] [ text model.coto.content ]
                        ]
                else
                    div [ class "coto-content" ]
                        [ App.Markdown.markdown model.coto.content ]
            ]
    , buttons =
        if model.editing then
            [ button
                [ class "button", onClick (AppMsg.CotoModalMsg CancelEditing) ]
                [ text "Cancel" ]
            , button
                [ class "button button-primary", onClick (AppMsg.CotoModalMsg Save) ]
                [ text "Save" ]
            ]
        else
            [ button
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
