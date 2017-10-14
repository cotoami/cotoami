module App.Modals.CotoModal
    exposing
        ( Model
        , initModel
        , setContentUpdating
        , setContentUpdated
        , setContentUpdateError
        , update
        , view
        )

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http exposing (Error(..))
import Util.Modal as Modal
import Util.StringUtil exposing (isNotBlank)
import App.Types.Coto
    exposing
        ( Coto
        , CotonomaKey
        , updateContent
        , cotonomaNameMaxlength
        , validateCotonomaName
        )
import App.Markdown
import App.Types.Session exposing (Session)
import App.Messages as AppMsg
    exposing
        ( Msg(CloseModal, ConfirmDeleteCoto, UpdateContent, PinOrUnpinCotonoma)
        )
import App.Views.Coto exposing (cotonomaLabel)
import App.Modals.CotoModalMsg as CotoModalMsg exposing (Msg(..))


type alias Model =
    { coto : Coto
    , cotonomaPinned : Bool
    , editing : Bool
    , editingContent : String
    , updatingContent : Bool
    , contentUpdateStatus : ContentUpdateStatus
    , updatingCotonomaPin : Bool
    }


type ContentUpdateStatus
    = None
    | Conflict
    | Rejected


initModel : Bool -> Coto -> Model
initModel cotonomaPinned coto =
    { coto = coto
    , cotonomaPinned = cotonomaPinned
    , editing = False
    , editingContent = coto.content
    , updatingContent = False
    , contentUpdateStatus = None
    , updatingCotonomaPin = False
    }


setContentUpdating : Model -> Model
setContentUpdating model =
    { model
        | updatingContent = True
        , contentUpdateStatus = None
    }


setContentUpdated : Coto -> Model -> Model
setContentUpdated coto model =
    { model
        | coto = coto
        , editing = False
        , updatingContent = False
        , contentUpdateStatus = None
    }


setContentUpdateError : Http.Error -> Model -> Model
setContentUpdateError error model =
    (case error of
        BadStatus response ->
            if response.status.code == 409 then
                { model | contentUpdateStatus = Conflict }
            else
                { model | contentUpdateStatus = Rejected }

        _ ->
            { model | contentUpdateStatus = Rejected }
    )
        |> \model -> { model | updatingContent = False }


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
                , contentUpdateStatus = None
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
    case model.coto.cotonomaKey of
        Nothing ->
            cotoModalConfig session model

        Just cotonomaKey ->
            cotonomaModalConfig cotonomaKey session model


cotoModalConfig : Session -> Model -> Modal.Config AppMsg.Msg
cotoModalConfig session model =
    { closeMessage = CloseModal
    , title = "Coto"
    , content =
        div []
            [ if model.editing then
                div []
                    [ div [ class "coto-editor" ]
                        [ textarea
                            [ class "coto"
                            , value model.editingContent
                            , onInput (AppMsg.CotoModalMsg << EditorInput)
                            ]
                            []
                        ]
                    , errorDiv model
                    ]
              else
                div [ class "coto-content" ]
                    [ App.Markdown.markdown model.coto.content ]
            ]
    , buttons =
        if model.editing then
            [ cancelEditingButton
            , saveButton
                (isNotBlank model.editingContent
                    && not model.updatingContent
                )
                model
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


cotonomaModalConfig : CotonomaKey -> Session -> Model -> Modal.Config AppMsg.Msg
cotonomaModalConfig cotonomaKey session model =
    { closeMessage = CloseModal
    , title = "Cotonoma"
    , content =
        div []
            [ if model.editing then
                div []
                    [ div [ class "coto-editor" ]
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
                    , errorDiv model
                    ]
              else
                div [ class "cotonoma" ]
                    [ cotonomaLabel model.coto.amishi model.coto.content ]
            ]
    , buttons =
        if model.editing then
            [ cancelEditingButton
            , saveButton
                (validateCotonomaName model.editingContent
                    && not model.updatingContent
                )
                model
            ]
        else
            [ if session.owner then
                button
                    [ class "button"
                    , disabled model.updatingCotonomaPin
                    , onClick (PinOrUnpinCotonoma cotonomaKey (not model.cotonomaPinned))
                    ]
                    [ text
                        (if model.updatingCotonomaPin then
                            "Processing..."
                         else if model.cotonomaPinned then
                            "Unpin from nav"
                         else
                            "Pin to nav"
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


saveButton : Bool -> Model -> Html AppMsg.Msg
saveButton enabled model =
    button
        [ class "button button-primary"
        , disabled (not enabled)
        , onClick (UpdateContent model.coto.id model.editingContent)
        ]
        [ text
            (if model.updatingContent then
                "Updating..."
             else
                "Save"
            )
        ]


checkWritePermission : Session -> Model -> Bool
checkWritePermission session model =
    (Maybe.map (\amishi -> amishi.id) model.coto.amishi) == (Just session.id)


errorDiv : Model -> Html AppMsg.Msg
errorDiv model =
    case model.contentUpdateStatus of
        Conflict ->
            div [ class "error" ]
                [ span [ class "message" ]
                    [ text "You already have this cotonoma." ]
                ]

        Rejected ->
            div [ class "error" ]
                [ span [ class "message" ]
                    [ text "An unexpected error has occurred." ]
                ]

        _ ->
            div [] []
