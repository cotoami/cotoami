module App.Modals.EditorModal
    exposing
        ( Model
        , initModel
        , getSummary
        , update
        , view
        )

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Util.Modal as Modal
import Util.StringUtil exposing (isBlank)
import Util.EventUtil exposing (onKeyDown)
import Util.HtmlUtil exposing (faIcon)
import App.Markdown
import App.Types.Coto exposing (Coto)
import App.Types.Context exposing (Context)
import App.Messages as AppMsg exposing (Msg(CloseModal, ConfirmPostAndConnect))
import App.Modals.EditorModalMsg as EditorModalMsg exposing (Msg(..))


type alias Model =
    { coto : Maybe Coto
    , summary : String
    , content : String
    , preview : Bool
    , requestProcessing : Bool
    }


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
    }


getSummary : Model -> Maybe String
getSummary model =
    if isBlank model.summary then
        Nothing
    else
        Just model.summary


update : EditorModalMsg.Msg -> Model -> ( Model, Cmd AppMsg.Msg )
update msg model =
    case msg of
        EditorInput content ->
            ( { model | content = content }, Cmd.none )

        SummaryInput summary ->
            ( { model | summary = summary }, Cmd.none )

        TogglePreview ->
            ( { model | preview = not model.preview }, Cmd.none )

        Post ->
            ( { model | requestProcessing = True }, Cmd.none )

        EditorKeyDown keyCode ->
            ( model, Cmd.none )


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
        ] ++ (buttonsForNew context model)
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
