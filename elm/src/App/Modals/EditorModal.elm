module App.Modals.EditorModal
    exposing
        ( Model
        , initModel
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
import Util.EventUtil exposing (onKeyDown)
import Util.HtmlUtil exposing (faIcon)
import App.Markdown
import App.Types.Coto exposing (Coto)
import App.Types.Context exposing (Context)
import App.Server.Coto
import App.Messages as AppMsg exposing (Msg(CloseModal, ConfirmPostAndConnect))
import App.Modals.EditorModalMsg as EditorModalMsg exposing (Msg(..))


type alias Model =
    { coto : Maybe Coto
    , summary : String
    , content : String
    , preview : Bool
    , requestProcessing : Bool
    , requestStatus : RequestStatus
    }


type RequestStatus
    = None
    | Conflict
    | Rejected


initModel : Maybe Coto -> Model
initModel maybeCoto =
    { coto = maybeCoto
    , summary =
        maybeCoto
            |> Maybe.map (\coto -> Maybe.withDefault "" coto.summary)
            |> Maybe.withDefault ""
    , content =
        maybeCoto
            |> Maybe.map (\coto -> coto.content)
            |> Maybe.withDefault ""
    , preview = False
    , requestProcessing = False
    , requestStatus = None
    }


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

        Save ->
            ( { model | requestProcessing = True }
            , model.coto
                |> Maybe.map
                    (\coto ->
                        App.Server.Coto.updateContent
                            coto.id
                            model.summary
                            model.content
                    )
                |> Maybe.withDefault Cmd.none
            )


view : Context -> Model -> Html AppMsg.Msg
view context model =
    modalConfig context model
        |> Just
        |> Modal.view "editor-modal"


modalConfig : Context -> Model -> Modal.Config AppMsg.Msg
modalConfig context model =
    { closeMessage = CloseModal
    , title =
        model.coto
            |> Maybe.map (\_ -> text "Edit Coto")
            |> Maybe.withDefault (text "New Coto")
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
            ++ (model.coto
                    |> Maybe.map (\_ -> buttonsForEdit model)
                    |> Maybe.withDefault (buttonsForNew context model)
               )
    }


cotoEditor : Model -> Html AppMsg.Msg
cotoEditor model =
    div [ class "coto-editor" ]
        [ div [ class "summary-input" ]
            [ input
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
                    , autofocus True
                    , onInput (AppMsg.EditorModalMsg << EditorInput)
                    , onKeyDown (AppMsg.EditorModalMsg << EditorKeyDown)
                    ]
                    []
                ]
        , errorDiv model
        ]


buttonsForNew : Context -> Model -> List (Html AppMsg.Msg)
buttonsForNew context model =
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
