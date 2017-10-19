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
import Util.DateUtil
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
    , editingToCotonomatize : Bool
    , editorContent : String
    , waitingToUpdateContent : Bool
    , contentUpdateStatus : ContentUpdateStatus
    , waitingToPinOrUnpinCotonoma : Bool
    , waitingToCotonomatize : Bool
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
    , editingToCotonomatize = False
    , editorContent = coto.content
    , waitingToUpdateContent = False
    , contentUpdateStatus = None
    , waitingToPinOrUnpinCotonoma = False
    , waitingToCotonomatize = False
    }


setContentUpdating : Model -> Model
setContentUpdating model =
    { model
        | waitingToUpdateContent = True
        , contentUpdateStatus = None
    }


setContentUpdated : Coto -> Model -> Model
setContentUpdated coto model =
    { model
        | coto = coto
        , editing = False
        , editingToCotonomatize = False
        , waitingToUpdateContent = False
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
        |> \model ->
            { model
                | waitingToUpdateContent = False
                , waitingToCotonomatize = False
                , editing = True
            }


setCotonomatized : Coto -> Model -> Model
setCotonomatized coto model =
    { model
        | coto = coto
        , waitingToCotonomatize = False
    }


update : CotoModalMsg.Msg -> Model -> ( Model, Maybe Confirmation, Cmd AppMsg.Msg )
update msg model =
    case msg of
        Edit ->
            ( { model | editing = True, editingToCotonomatize = False }
            , Nothing
            , Cmd.none
            )

        EditorInput content ->
            ( { model | editorContent = content }, Nothing, Cmd.none )

        CancelEditing ->
            ( { model
                | editing = False
                , editingToCotonomatize = False
                , editorContent = model.coto.content
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
                model.editorContent
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
                ( { model | editing = True, editingToCotonomatize = True }
                , Nothing
                , Cmd.none
                )

        Cotonomatize ->
            ( { model | waitingToCotonomatize = True }
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
    model.coto.cotonomaKey
        |> Maybe.map (\key -> cotonomaModalConfig key session model)
        |> Maybe.withDefault (cotoModalConfig session model)


cotoModalConfig : Session -> Model -> Modal.Config AppMsg.Msg
cotoModalConfig session model =
    { closeMessage = CloseModal
    , title =
        span [ class "coto-modal-title" ]
            [ text "Coto"
            , if checkWritePermission session model && (not model.editing) then
                button
                    [ class "button"
                    , onClick (AppMsg.CotoModalMsg ConfirmCotonomatize)
                    ]
                    (if model.waitingToCotonomatize then
                        [ text "Converting..." ]
                     else
                        [ faIcon "long-arrow-right" Nothing
                        , text "Cotonomatize"
                        ]
                    )
              else
                span [] []
            ]
    , content =
        div []
            [ if model.editing then
                div [ class "coto-editor" ]
                    [ adviceOnCotonomaNameDiv model
                    , div [ class "content-input" ]
                        [ textarea
                            [ value model.editorContent
                            , onInput (AppMsg.CotoModalMsg << EditorInput)
                            ]
                            []
                        ]
                    , errorDiv model
                    ]
              else
                div [ class "coto-view" ]
                    [ App.Markdown.markdown model.coto.content
                    , cotoInfo model.coto
                    ]
            ]
    , buttons =
        if model.editing then
            [ cancelEditingButton
            , saveButton
                (isNotBlank model.editorContent
                    && not model.waitingToUpdateContent
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
                div [ class "cotonoma-editor" ]
                    [ div [ class "name-input" ]
                        [ input
                            [ type_ "text"
                            , class "u-full-width"
                            , placeholder "Cotonoma name"
                            , maxlength cotonomaNameMaxlength
                            , value model.editorContent
                            , onInput (AppMsg.CotoModalMsg << EditorInput)
                            ]
                            []
                        ]
                    , errorDiv model
                    ]
              else
                div [ class "cotonoma-view" ]
                    [ div [ class "cotonoma" ]
                        [ cotonomaLabel model.coto.amishi model.coto.content ]
                    , cotoInfo model.coto
                    ]
            ]
    , buttons =
        if model.editing then
            [ cancelEditingButton
            , saveButton
                (validateCotonomaName model.editorContent
                    && not model.waitingToUpdateContent
                )
                model
            ]
        else
            [ if session.owner then
                button
                    [ class "button"
                    , disabled model.waitingToPinOrUnpinCotonoma
                    , onClick (PinOrUnpinCotonoma cotonomaKey (not model.cotonomaPinned))
                    ]
                    [ text
                        (if model.waitingToPinOrUnpinCotonoma then
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


cotoInfo : Coto -> Html AppMsg.Msg
cotoInfo coto =
    div [ class "coto-info" ]
        [ authorSpan coto
        , text " "
        , postedAtSpan coto
        , text " "
        , postedInSpan coto
        ]


authorSpan : Coto -> Html AppMsg.Msg
authorSpan coto =
    coto.amishi
        |> Maybe.map
            (\author ->
                span [ class "amishi author" ]
                    [ span [ class "preposition" ] [ text "by" ]
                    , img [ class "avatar", src author.avatarUrl ] []
                    , span [ class "name" ] [ text author.displayName ]
                    ]
            )
        |> Maybe.withDefault (span [] [])


postedAtSpan : Coto -> Html AppMsg.Msg
postedAtSpan coto =
    span [ class "posted-at" ]
        [ span [ class "preposition" ] [ text "at" ]
        , span [ class "datetime" ]
            [ text (Util.DateUtil.format "en_us" "%Y/%m/%d %H:%M" coto.postedAt) ]
        ]


postedInSpan : Coto -> Html AppMsg.Msg
postedInSpan coto =
    coto.postedIn
        |> Maybe.map
            (\postedIn ->
                span [ class "posted-in" ]
                    [ span [ class "preposition" ] [ text "in" ]
                    , span [ class "cotonoma-name" ] [ text postedIn.name ]
                    ]
            )
        |> Maybe.withDefault (span [] [])


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
            (if model.waitingToUpdateContent then
                "Updating..."
             else
                "Save"
            )
        ]


checkWritePermission : Session -> Model -> Bool
checkWritePermission session model =
    (Maybe.map (\amishi -> amishi.id) model.coto.amishi) == (Just session.id)


adviceOnCotonomaNameDiv : Model -> Html AppMsg.Msg
adviceOnCotonomaNameDiv model =
    if model.editingToCotonomatize then
        let
            contentLength =
                String.length model.editorContent
        in
            div [ class "advice-on-cotonoma-name" ]
                [ text
                    ("A cotonoma name have to be under "
                        ++ (toString cotonomaNameMaxlength)
                        ++ " characters, currently: "
                    )
                , span
                    [ class
                        (if contentLength > cotonomaNameMaxlength then
                            "too-long"
                         else
                            "ok"
                        )
                    ]
                    [ text (toString contentLength) ]
                ]
    else
        div [] []


errorDiv : Model -> Html AppMsg.Msg
errorDiv model =
    case model.contentUpdateStatus of
        Conflict ->
            div [ class "error" ]
                [ span [ class "message" ]
                    [ text "You already have a cotonoma with this name." ]
                ]

        Rejected ->
            div [ class "error" ]
                [ span [ class "message" ]
                    [ text "An unexpected error has occurred." ]
                ]

        _ ->
            div [] []
