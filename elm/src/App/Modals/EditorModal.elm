module App.Modals.EditorModal
    exposing
        ( Model
        , Mode(..)
        , defaultModel
        , initModel
        , editToCotonomatize
        , getSummary
        , setCotoSaveError
        , update
        , view
        )

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http exposing (Error(..))
import Util.Modal as Modal
import Util.StringUtil exposing (isBlank)
import Util.EventUtil exposing (onKeyDown, onLinkButtonClick)
import Util.HtmlUtil exposing (faIcon)
import App.Markdown
import App.Types.Coto exposing (Coto)
import App.Types.Context exposing (Context)
import App.Server.Coto
import App.Messages as AppMsg exposing (Msg(CloseModal, ConfirmPostAndConnect))
import App.Modals.EditorModalMsg as EditorModalMsg exposing (Msg(..))


type alias Model =
    { mode : Mode
    , summary : String
    , content : String
    , preview : Bool
    , requestProcessing : Bool
    , requestStatus : RequestStatus
    , editingToCotonomatize : Bool
    }


type Mode
    = NewCoto
    | NewCotonoma
    | Edit Coto


type RequestStatus
    = None
    | Conflict
    | Rejected


defaultModel : Model
defaultModel =
    { mode = NewCoto
    , summary = ""
    , content = ""
    , preview = False
    , requestProcessing = False
    , requestStatus = None
    , editingToCotonomatize = False
    }


initModel : Mode -> Model
initModel mode =
    { defaultModel
        | mode = mode
        , summary =
            case mode of
                Edit coto ->
                    Maybe.withDefault "" coto.summary

                _ ->
                    ""
        , content =
            case mode of
                Edit coto ->
                    coto.content

                _ ->
                    ""
    }


editToCotonomatize : Coto -> Model
editToCotonomatize coto =
    initModel (Edit coto)
        |> \model -> { model | editingToCotonomatize = True }


getSummary : Model -> Maybe String
getSummary model =
    if isBlank model.summary then
        Nothing
    else
        Just model.summary


setCotoSaveError : Http.Error -> Model -> Model
setCotoSaveError error model =
    (case error of
        BadStatus response ->
            if response.status.code == 409 then
                { model | requestStatus = Conflict }
            else
                { model | requestStatus = Rejected }

        _ ->
            { model | requestStatus = Rejected }
    )
        |> \model ->
            { model
                | preview = False
                , requestProcessing = False
            }


update : EditorModalMsg.Msg -> Model -> ( Model, Cmd AppMsg.Msg )
update msg model =
    case msg of
        EditorInput content ->
            ( { model | content = content }, Cmd.none )

        SummaryInput summary ->
            ( { model | summary = summary }, Cmd.none )

        TogglePreview ->
            ( { model | preview = not model.preview }, Cmd.none )

        EditorKeyDown keyCode ->
            ( model, Cmd.none )

        Post ->
            ( { model | requestProcessing = True }, Cmd.none )

        PostCotonoma ->
            ( { model | requestProcessing = True }, Cmd.none )

        Save ->
            ( { model | requestProcessing = True }
            , case model.mode of
                Edit coto ->
                    App.Server.Coto.updateContent
                        coto.id
                        model.summary
                        model.content

                _ ->
                    Cmd.none
            )

        SetNewCotoMode ->
            ( { model | mode = NewCoto }, Cmd.none )

        SetNewCotonomaMode ->
            ( { model | mode = NewCotonoma }, Cmd.none )


view : Context -> Model -> Html AppMsg.Msg
view context model =
    (case model.mode of
        Edit coto ->
            if coto.asCotonoma then
                cotonomaEditorConfig context model
            else
                cotoEditorConfig context model

        NewCoto ->
            cotoEditorConfig context model

        NewCotonoma ->
            cotonomaEditorConfig context model
    )
        |> Just
        |> Modal.view "editor-modal"



--
-- Coto Editor
--


cotoEditorConfig : Context -> Model -> Modal.Config AppMsg.Msg
cotoEditorConfig context model =
    { closeMessage = CloseModal
    , title =
        case model.mode of
            Edit coto ->
                text "Edit Coto"

            _ ->
                div []
                    [ text "New Coto or "
                    , a
                        [ class "switch-to"
                        , onLinkButtonClick (AppMsg.EditorModalMsg SetNewCotonomaMode)
                        ]
                        [ text "Cotonoma" ]
                    ]
    , content =
        div [] [ cotoEditor model ]
    , buttons =
        [ button
            [ class "button preview"
            , disabled (isBlank model.content || model.requestProcessing)
            , onClick (AppMsg.EditorModalMsg TogglePreview)
            ]
            [ (if model.preview then
                text "Edit"
               else
                text "Preview"
              )
            ]
        ]
            ++ (case model.mode of
                    Edit coto ->
                        buttonsForEdit model

                    _ ->
                        buttonsForNewCoto context model
               )
    }


cotoEditor : Model -> Html AppMsg.Msg
cotoEditor model =
    div [ class "coto-editor" ]
        [ div [ class "summary-input" ]
            [ adviceOnCotonomaNameDiv model
            , if model.editingToCotonomatize then
                div [] []
              else
                input
                    [ type_ "text"
                    , class "u-full-width"
                    , placeholder "Summary (optional)"
                    , maxlength App.Types.Coto.summaryMaxlength
                    , value model.summary
                    , onInput (AppMsg.EditorModalMsg << SummaryInput)
                    ]
                    []
            ]
        , if model.preview then
            div [ class "content-preview" ]
                [ App.Markdown.markdown model.content ]
          else
            div [ class "content-input" ]
                [ textarea
                    [ id "editor-modal-content-input"
                    , value model.content
                    , onInput (AppMsg.EditorModalMsg << EditorInput)
                    , case model.mode of
                        NewCoto ->
                            onKeyDown (AppMsg.EditorModalMsg << EditorKeyDown)

                        _ ->
                            autofocus True
                    ]
                    []
                ]
        , errorDiv model
        ]



--
-- Cotonoma Editor
--


cotonomaEditorConfig : Context -> Model -> Modal.Config AppMsg.Msg
cotonomaEditorConfig context model =
    { closeMessage = CloseModal
    , title =
        case model.mode of
            Edit coto ->
                text "Change Cotonoma Name"

            _ ->
                div []
                    [ text "New "
                    , a
                        [ class "switch-to"
                        , onLinkButtonClick (AppMsg.EditorModalMsg SetNewCotoMode)
                        ]
                        [ text "Coto" ]
                    , text " or Cotonoma"
                    ]
    , content =
        div [] [ cotonomaEditor model ]
    , buttons =
        case model.mode of
            Edit coto ->
                buttonsForEdit model

            _ ->
                buttonsForNewCotonoma context model
    }


cotonomaEditor : Model -> Html AppMsg.Msg
cotonomaEditor model =
    div [ class "cotonoma-editor" ]
        [ case model.mode of
            NewCotonoma ->
                div [ class "cotonoma-help" ]
                    [ text
                        ("A Cotonoma is a dedicated place where you can keep Cotos or"
                            ++ " discuss with others about a topic described by its name."
                        )
                    ]

            _ ->
                div [] []
        , div [ class "name-input" ]
            [ input
                [ type_ "text"
                , class "u-full-width"
                , placeholder "Cotonoma name"
                , maxlength App.Types.Coto.cotonomaNameMaxlength
                , value model.content
                , onInput (AppMsg.EditorModalMsg << EditorInput)
                ]
                []
            ]
        , errorDiv model
        ]



--
-- Partials
--


buttonsForNewCoto : Context -> Model -> List (Html AppMsg.Msg)
buttonsForNewCoto context model =
    [ if List.isEmpty context.selection then
        span [] []
      else
        button
            [ class "button connect"
            , disabled (isBlank model.content || model.requestProcessing)
            , onClick (ConfirmPostAndConnect model.content (getSummary model))
            ]
            [ faIcon "link" Nothing
            , span [ class "shortcut-help" ] [ text "(Alt + Enter)" ]
            ]
    , button
        [ class "button button-primary"
        , disabled (isBlank model.content || model.requestProcessing)
        , onClick (AppMsg.EditorModalMsg Post)
        ]
        (if model.requestProcessing then
            [ text "Posting..." ]
         else
            [ text "Post"
            , span [ class "shortcut-help" ] [ text "(Ctrl + Enter)" ]
            ]
        )
    ]


buttonsForNewCotonoma : Context -> Model -> List (Html AppMsg.Msg)
buttonsForNewCotonoma context model =
    [ button
        [ class "button button-primary"
        , disabled (isBlank model.content || model.requestProcessing)
        , onClick (AppMsg.EditorModalMsg PostCotonoma)
        ]
        (if model.requestProcessing then
            [ text "Posting..." ]
         else
            [ text "Post" ]
        )
    ]


buttonsForEdit : Model -> List (Html AppMsg.Msg)
buttonsForEdit model =
    [ button
        [ class "button button-primary"
        , disabled (isBlank model.content || model.requestProcessing)
        , onClick (AppMsg.EditorModalMsg Save)
        ]
        (if model.requestProcessing then
            [ text "Saving..." ]
         else
            [ text "Save" ]
        )
    ]


errorDiv : Model -> Html AppMsg.Msg
errorDiv model =
    case model.requestStatus of
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


adviceOnCotonomaNameDiv : Model -> Html AppMsg.Msg
adviceOnCotonomaNameDiv model =
    if model.editingToCotonomatize then
        let
            contentLength =
                String.length model.content

            maxlength =
                App.Types.Coto.cotonomaNameMaxlength
        in
            div [ class "advice-on-cotonoma-name" ]
                [ text
                    ("A cotonoma name have to be under "
                        ++ (toString maxlength)
                        ++ " characters, currently: "
                    )
                , span
                    [ class
                        (if contentLength > maxlength then
                            "too-long"
                         else
                            "ok"
                        )
                    ]
                    [ text (toString contentLength) ]
                ]
    else
        div [] []
