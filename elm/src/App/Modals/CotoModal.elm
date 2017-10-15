module App.Modals.CotoModal
    exposing
        ( Model
        , initModel
        , setContentUpdated
        , setContentUpdateError
        , setCotonomatized
        , update
        , view
        )

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http exposing (Error(..))
import Util.Modal as Modal
import Util.StringUtil exposing (isNotBlank)
import Util.HtmlUtil exposing (faIcon)
import App.Markdown
import App.Types.Coto
    exposing
        ( Coto
        , CotonomaKey
        , updateContent
        , cotonomaNameMaxlength
        , validateCotonomaName
        )
import App.Types.Session exposing (Session)
import App.Server.Coto
import App.Messages as AppMsg
    exposing
        ( Msg(CloseModal, ConfirmDeleteCoto, PinOrUnpinCotonoma)
        )
import App.Confirmation exposing (Confirmation)
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
    , cotonomatizing : Bool
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
    , cotonomatizing = False
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


setCotonomatized : Coto -> Model -> Model
setCotonomatized coto model =
    { model
        | coto = coto
        , cotonomatizing = False
    }


update : CotoModalMsg.Msg -> Model -> ( Model, Maybe Confirmation, Cmd AppMsg.Msg )
update msg model =
    case msg of
        Edit ->
            ( { model | editing = True }, Nothing, Cmd.none )

        EditorInput content ->
            ( { model | editingContent = content }, Nothing, Cmd.none )

        CancelEditing ->
            ( { model
                | editing = False
                , editingContent = model.coto.content
                , contentUpdateStatus = None
              }
            , Nothing
            , Cmd.none
            )

        Save ->
            ( setContentUpdating model
            , Nothing
            , App.Server.Coto.updateContent
                model.coto.id
                model.editingContent
            )

        ConfirmCotonomatize ->
            if String.length model.coto.content <= cotonomaNameMaxlength then
                ( model
                , Just <|
                    Confirmation
                        "Are you sure you want to convert this coto into a cotonoma?"
                        (AppMsg.CotoModalMsg Cotonomatize)
                , Cmd.none
                )
            else
                ( model, Nothing, Cmd.none )

        Cotonomatize ->
            ( { model | cotonomatizing = True }
            , Nothing
            , App.Server.Coto.cotonomatize model.coto.id
            )


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
    , title =
        span [ class "coto-modal-title" ]
            [ text "Coto"
            , if model.editing then
                span [] []
              else
                button
                    [ class "button"
                    , onClick (AppMsg.CotoModalMsg ConfirmCotonomatize)
                    ]
                    (if model.cotonomatizing then
                        [ text "Converting..." ]
                     else
                        [ faIcon "long-arrow-right" Nothing
                        , text "Cotonomatize"
                        ]
                    )
            ]
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
    , title = text "Cotonoma"
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
        , onClick (AppMsg.CotoModalMsg Save)
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
