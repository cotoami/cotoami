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
import App.Types.Coto exposing (Coto)
import App.Messages as AppMsg exposing (Msg(CloseModal))
import App.Modals.EditorModalMsg as EditorModalMsg exposing (Msg(..))


type alias Model =
    { coto : Maybe Coto
    , summary : String
    , content : String
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

        Post ->
            ( { model | requestProcessing = True }, Cmd.none )

        EditorKeyDown keyCode ->
            ( model, Cmd.none )


view : Model -> Html AppMsg.Msg
view model =
    modalConfig model
        |> Just
        |> Modal.view "editor-modal"


modalConfig : Model -> Modal.Config AppMsg.Msg
modalConfig model =
    { closeMessage = CloseModal
    , title = text "New Coto"
    , content =
        div [] [ cotoEditor model ]
    , buttons =
        [ button
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
        , div [ class "content-input" ]
            [ textarea
                [ id "editor-modal-content-input"
                , value model.content
                , onInput (AppMsg.EditorModalMsg << EditorInput)
                , onKeyDown (AppMsg.EditorModalMsg << EditorKeyDown)
                ]
                []
            ]
        ]
