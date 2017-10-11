module App.Modals.CotoModal exposing (Model, initModel, update, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Util.Modal as Modal
import Util.StringUtil exposing (isBlank)
import App.Types.Coto
    exposing
        ( Coto
        , updateContent
        , cotonomaNameMaxlength
        , validateCotonomaName
        )
import App.Markdown
import App.Types.Session exposing (Session)
import App.Messages as AppMsg exposing (Msg(CloseModal, ConfirmDeleteCoto))
import App.Views.Coto exposing (cotonomaLabel)
import App.Modals.CotoModalMsg as CotoModalMsg exposing (Msg(..))


type alias Model =
    { coto : Coto
    , cotonomaPinned : Bool
    , editing : Bool
    , editingContent : String
    }


initModel : Bool -> Coto -> Model
initModel cotonomaPinned coto =
    { coto = coto
    , cotonomaPinned = cotonomaPinned
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


view : Maybe Session -> Maybe Model -> Html AppMsg.Msg
view maybeSession maybeModel =
    maybeModel
        |> Maybe.andThen
            (\model ->
                maybeSession |> Maybe.map (\session -> modalConfig session model)
            )
        |> Modal.view "coto-modal"


modalConfig : Session -> Model -> Modal.Config AppMsg.Msg
modalConfig session model =
    if model.coto.asCotonoma then
        cotonomaModalConfig session model
    else
        cotoModalConfig session model


cotoModalConfig : Session -> Model -> Modal.Config AppMsg.Msg
cotoModalConfig session model =
    { closeMessage = CloseModal
    , title = "Coto"
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
        if model.editing then
            [ cancelEditingButton
            , button
                [ class "button button-primary"
                , disabled (isBlank model.editingContent)
                , onClick (AppMsg.CotoModalMsg Save)
                ]
                [ text "Save" ]
            ]
        else if checkWritePermission session model then
            [ editButton
            , button
                [ class "button", onClick ConfirmDeleteCoto ]
                [ text "Delete" ]
            ]
        else
            []
    }


cotonomaModalConfig : Session -> Model -> Modal.Config AppMsg.Msg
cotonomaModalConfig session model =
    { closeMessage = CloseModal
    , title = "Cotonoma"
    , content =
        div []
            [ if model.editing then
                div [ class "coto-editor" ]
                    [ input
                        [ type_ "text"
                        , class "u-full-width"
                        , placeholder "Cotonoma name"
                        , maxlength cotonomaNameMaxlength
                        , value model.editingContent
                        , onInput (AppMsg.CotoModalMsg << EditorInput)
                        ]
                        []
                    ]
              else
                div [ class "cotonoma" ]
                    [ cotonomaLabel model.coto.amishi model.coto.content ]
            ]
    , buttons =
        if model.editing then
            [ cancelEditingButton
            , button
                [ class "button button-primary"
                , disabled (not (validateCotonomaName model.editingContent))
                , onClick (AppMsg.CotoModalMsg Save)
                ]
                [ text "Save" ]
            ]
        else
            [ if session.owner then
                button
                    [ class "button" ]
                    [ text
                        (if model.cotonomaPinned then
                            "Unpin"
                         else
                            "Pin"
                        )
                    ]
              else
                span [] []
            , if checkWritePermission session model then
                editButton
              else
                span [] []
            ]
    }


cancelEditingButton : Html AppMsg.Msg
cancelEditingButton =
    button
        [ class "button", onClick (AppMsg.CotoModalMsg CancelEditing) ]
        [ text "Cancel" ]


editButton : Html AppMsg.Msg
editButton =
    button
        [ class "button", onClick (AppMsg.CotoModalMsg Edit) ]
        [ text "Edit" ]


checkWritePermission : Session -> Model -> Bool
checkWritePermission session model =
    (Maybe.map (\amishi -> amishi.id) model.coto.amishi) == (Just session.id)
