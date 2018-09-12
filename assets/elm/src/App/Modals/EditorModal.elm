module App.Modals.EditorModal
    exposing
        ( Model
        , Mode(..)
        , defaultModel
        , modelForNew
        , modelForEdit
        , modelForEditToCotonomatize
        , getSummary
        , setCotoSaveError
        , update
        , view
        )

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on, onClick, onInput, onCheck)
import Http exposing (Error(..))
import Json.Decode as Decode
import Exts.Maybe exposing (isJust)
import Util.Modal as Modal
import Util.StringUtil exposing (isBlank, isNotBlank)
import Util.EventUtil exposing (onKeyDown, onLinkButtonClick)
import Util.HtmlUtil exposing (faIcon, materialIcon)
import Util.UpdateUtil exposing (withCmd, withoutCmd, addCmd)
import Util.Keyboard.Key
import Util.Keyboard.Event exposing (KeyboardEvent)
import App.Markdown
import Util.Keyboard.Event
import App.Types.Coto exposing (Coto)
import App.Types.Post exposing (Post)
import App.Types.Timeline
import App.Types.Graph
import App.Submodels.Context exposing (Context)
import App.Submodels.Modals exposing (Modals)
import App.Submodels.LocalCotos exposing (LocalCotos)
import App.Commands
import App.Server.Coto
import App.Server.Post
import App.Server.Graph
import App.Messages as AppMsg exposing (Msg(CloseModal))
import App.Modals.EditorModalMsg as EditorModalMsg exposing (Msg(..))
import App.Views.Coto
import App.Views.Timeline


type alias Model =
    { mode : Mode
    , source : Maybe Coto
    , summary : String
    , content : String
    , shareCotonoma : Bool
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
    , source = Nothing
    , summary = ""
    , content = ""
    , shareCotonoma = False
    , preview = False
    , requestProcessing = False
    , requestStatus = None
    , editingToCotonomatize = False
    }


modelForNew : Context a -> Maybe Coto -> Model
modelForNew context source =
    { defaultModel
        | mode = NewCoto
        , source = source
        , shareCotonoma =
            context.cotonoma
                |> Maybe.map (\cotonoma -> cotonoma.shared)
                |> Maybe.withDefault False
    }


modelForEdit : Coto -> Model
modelForEdit coto =
    { defaultModel
        | mode = Edit coto
        , summary = Maybe.withDefault "" coto.summary
        , content = coto.content
        , shareCotonoma =
            coto.asCotonoma
                |> Maybe.map (\cotonoma -> cotonoma.shared)
                |> Maybe.withDefault False
    }


modelForEditToCotonomatize : Coto -> Model
modelForEditToCotonomatize coto =
    modelForEdit coto
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


type alias AppModel a =
    LocalCotos (Modals { a | editorModal : Model })


update : Context a -> EditorModalMsg.Msg -> AppModel b -> ( AppModel b, Cmd AppMsg.Msg )
update context msg ({ editorModal, timeline } as model) =
    case msg of
        EditorInput content ->
            { model | editorModal = { editorModal | content = content } }
                |> withoutCmd

        SummaryInput summary ->
            { model | editorModal = { editorModal | summary = summary } }
                |> withoutCmd

        TogglePreview ->
            { model | editorModal = { editorModal | preview = not editorModal.preview } }
                |> withoutCmd

        EditorKeyDown keyboardEvent ->
            handleShortcut context keyboardEvent model

        ShareCotonomaCheck check ->
            { model | editorModal = { editorModal | shareCotonoma = check } }
                |> withoutCmd

        Post ->
            { model | editorModal = { editorModal | requestProcessing = True } }
                |> post context

        ConfirmPostAndConnect content summary ->
            App.Submodels.Modals.confirmPostAndConnect summary content model

        PostedAndSubordinateToCoto postId coto (Ok response) ->
            { model | timeline = App.Types.Timeline.setCotoSaved postId response timeline }
                |> App.Submodels.Modals.clearModals
                |> subordinatePostToCoto context coto response

        PostedAndSubordinateToCoto postId coto (Err _) ->
            model |> withoutCmd

        PostCotonoma ->
            { model | editorModal = { editorModal | requestProcessing = True } }
                |> postCotonoma context

        Save ->
            { model | editorModal = { editorModal | requestProcessing = True } }
                |> withCmd
                    (\model ->
                        case model.editorModal.mode of
                            Edit coto ->
                                App.Server.Coto.updateContent
                                    context.clientId
                                    coto.id
                                    model.editorModal.shareCotonoma
                                    model.editorModal.summary
                                    model.editorModal.content

                            _ ->
                                Cmd.none
                    )

        SetNewCotoMode ->
            { model | editorModal = { editorModal | mode = NewCoto } }
                |> withoutCmd

        SetNewCotonomaMode ->
            { model | editorModal = { editorModal | mode = NewCotonoma } }
                |> withoutCmd


post : Context a -> AppModel b -> ( AppModel b, Cmd AppMsg.Msg )
post context ({ editorModal, timeline } as model) =
    let
        summary =
            getSummary editorModal

        content =
            editorModal.content
    in
        editorModal.source
            |> Maybe.map (\source -> postSubcoto context source summary content model)
            |> Maybe.withDefault
                (App.Views.Timeline.post context summary content timeline
                    |> Tuple.mapFirst (\timeline -> { model | timeline = timeline })
                )


postSubcoto : Context a -> Coto -> Maybe String -> String -> AppModel b -> ( AppModel b, Cmd AppMsg.Msg )
postSubcoto context coto summary content model =
    let
        ( timeline, newPost ) =
            model.timeline
                |> App.Types.Timeline.post context False summary content
    in
        { model | timeline = timeline }
            ! [ App.Commands.scrollTimelineToBottom AppMsg.NoOp
              , App.Server.Post.post
                    context.clientId
                    context.cotonoma
                    (AppMsg.EditorModalMsg
                        << (PostedAndSubordinateToCoto timeline.postIdCounter coto)
                    )
                    newPost
              ]


subordinatePostToCoto : Context a -> Coto -> Post -> AppModel b -> ( AppModel b, Cmd AppMsg.Msg )
subordinatePostToCoto { clientId, session } coto post model =
    post.cotoId
        |> Maybe.andThen (\cotoId -> App.Submodels.LocalCotos.getCoto cotoId model)
        |> Maybe.map
            (\target ->
                let
                    direction =
                        App.Types.Graph.Inbound

                    maybeCotonomaKey =
                        Maybe.map (\cotonoma -> cotonoma.key) model.cotonoma
                in
                    ( App.Submodels.LocalCotos.connect
                        session
                        direction
                        [ coto ]
                        target
                        model
                    , App.Server.Graph.connect
                        clientId
                        maybeCotonomaKey
                        direction
                        [ coto.id ]
                        target.id
                    )
            )
        |> Maybe.withDefault ( model, Cmd.none )


handleShortcut : Context a -> KeyboardEvent -> AppModel b -> ( AppModel b, Cmd AppMsg.Msg )
handleShortcut context keyboardEvent model =
    if
        (keyboardEvent.keyCode == Util.Keyboard.Key.Enter)
            && isNotBlank model.editorModal.content
    then
        case model.editorModal.mode of
            Edit coto ->
                if keyboardEvent.ctrlKey || keyboardEvent.metaKey then
                    ( model
                    , App.Server.Coto.updateContent
                        context.clientId
                        coto.id
                        model.editorModal.shareCotonoma
                        model.editorModal.summary
                        model.editorModal.content
                    )
                else
                    ( model, Cmd.none )

            _ ->
                if keyboardEvent.ctrlKey || keyboardEvent.metaKey then
                    post context model
                else if
                    keyboardEvent.altKey
                        && App.Submodels.Context.anySelection context
                then
                    App.Submodels.Modals.confirmPostAndConnect
                        (getSummary model.editorModal)
                        model.editorModal.content
                        model
                else
                    ( model, Cmd.none )
    else
        ( model, Cmd.none )


postCotonoma : Context a -> AppModel b -> ( AppModel b, Cmd AppMsg.Msg )
postCotonoma context model =
    let
        cotonomaName =
            model.editorModal.content

        ( timeline, _ ) =
            App.Types.Timeline.post
                context
                True
                Nothing
                cotonomaName
                model.timeline
    in
        { model | timeline = timeline }
            ! [ App.Commands.scrollTimelineToBottom AppMsg.NoOp
              , App.Server.Post.postCotonoma
                    context.clientId
                    model.cotonoma
                    timeline.postIdCounter
                    model.editorModal.shareCotonoma
                    cotonomaName
              ]


view : Context a -> Model -> Html AppMsg.Msg
view context model =
    (case model.mode of
        Edit coto ->
            if isJust coto.asCotonoma then
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


cotoEditorConfig : Context a -> Model -> Modal.Config AppMsg.Msg
cotoEditorConfig context model =
    { closeMessage = CloseModal
    , title =
        case model.mode of
            Edit coto ->
                text "Edit Coto"

            _ ->
                newEditorTitle model
    , content =
        div [ class "coto-editor-modal-body" ]
            [ sourceCotoDiv context model
            , cotoEditor model
            ]
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
                        buttonsForEdit coto model

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
                Util.HtmlUtil.none
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
                    , placeholder "Write your Coto in Markdown"
                    , defaultValue model.content
                    , onInput (AppMsg.EditorModalMsg << EditorInput)
                    , on "keydown" <|
                        Decode.map
                            (AppMsg.EditorModalMsg << EditorKeyDown)
                            Util.Keyboard.Event.decodeKeyboardEvent
                    ]
                    []
                ]
        , errorDiv model
        ]



--
-- Cotonoma Editor
--


cotonomaEditorConfig : Context a -> Model -> Modal.Config AppMsg.Msg
cotonomaEditorConfig context model =
    { closeMessage = CloseModal
    , title =
        case model.mode of
            Edit coto ->
                text "Change Cotonoma Name"

            _ ->
                newEditorTitle model
    , content =
        div []
            [ sourceCotoDiv context model
            , cotonomaEditor model
            ]
    , buttons =
        case model.mode of
            Edit coto ->
                buttonsForEdit coto model

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
                        ("A Cotonoma is a special Coto that has a dedicated chat timeline"
                            ++ " where you can discuss with others about a topic described by its name."
                        )
                    ]

            _ ->
                Util.HtmlUtil.none
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
        , div [ class "shared-checkbox pretty p-default p-curve p-smooth" ]
            [ input
                [ type_ "checkbox"
                , checked model.shareCotonoma
                , onCheck (AppMsg.EditorModalMsg << ShareCotonomaCheck)
                ]
                []
            , div [ class "state" ]
                [ label []
                    [ span []
                        [ span [ class "label" ]
                            [ text "Share it with other users." ]
                        , span [ class "note" ]
                            [ text " (Only those who know the Cotonoma URL can access it)" ]
                        ]
                    ]
                ]
            ]
        , errorDiv model
        ]



--
-- Partials
--


newEditorTitle : Model -> Html AppMsg.Msg
newEditorTitle model =
    (case model.mode of
        NewCoto ->
            if isJust model.source then
                [ text "New Connected Coto" ]
            else
                [ text "New Coto or "
                , a
                    [ class "switch-to"
                    , onLinkButtonClick (AppMsg.EditorModalMsg SetNewCotonomaMode)
                    ]
                    [ text "Cotonoma" ]
                ]

        NewCotonoma ->
            [ text "New "
            , a
                [ class "switch-to"
                , onLinkButtonClick (AppMsg.EditorModalMsg SetNewCotoMode)
                ]
                [ text "Coto" ]
            , text " or Cotonoma"
            ]

        _ ->
            []
    )
        |> (div [])


sourceCotoDiv : Context a -> Model -> Html AppMsg.Msg
sourceCotoDiv context model =
    model.source
        |> Maybe.map
            (\source ->
                div [ class "source-coto" ]
                    [ App.Views.Coto.bodyDiv
                        context
                        "source-coto"
                        App.Markdown.markdown
                        source
                    , div [ class "arrow" ]
                        [ materialIcon "arrow_downward" Nothing ]
                    ]
            )
        |> Maybe.withDefault Util.HtmlUtil.none


buttonsForNewCoto : Context a -> Model -> List (Html AppMsg.Msg)
buttonsForNewCoto context model =
    [ if List.isEmpty context.selection || isJust model.source then
        Util.HtmlUtil.none
      else
        button
            [ class "button connect"
            , disabled (isBlank model.content || model.requestProcessing)
            , onClick (AppMsg.EditorModalMsg (ConfirmPostAndConnect model.content (getSummary model)))
            ]
            [ faIcon "link" Nothing
            , span [ class "shortcut-help" ] [ text "(Alt + Enter)" ]
            ]
    , button
        [ class "button button-primary"
        , disabled (isBlank model.content || model.requestProcessing)
        , onClick (AppMsg.EditorModalMsg EditorModalMsg.Post)
        ]
        (if model.requestProcessing then
            [ text "Posting..." ]
         else
            [ text "Post"
            , span [ class "shortcut-help" ] [ text "(Ctrl + Enter)" ]
            ]
        )
    ]


buttonsForNewCotonoma : Context a -> Model -> List (Html AppMsg.Msg)
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


buttonsForEdit : Coto -> Model -> List (Html AppMsg.Msg)
buttonsForEdit coto model =
    [ button
        [ class "button button-primary"
        , disabled (isBlank model.content || model.requestProcessing)
        , onClick (AppMsg.EditorModalMsg Save)
        ]
        (if model.requestProcessing then
            [ text "Saving..." ]
         else
            [ text "Save"
            , if isJust coto.asCotonoma then
                Util.HtmlUtil.none
              else
                span [ class "shortcut-help" ] [ text "(Ctrl + Enter)" ]
            ]
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
            Util.HtmlUtil.none


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
        Util.HtmlUtil.none
