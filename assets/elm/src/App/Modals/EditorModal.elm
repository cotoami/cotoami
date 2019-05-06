module App.Modals.EditorModal exposing
    ( Mode(..)
    , Model
    , defaultModel
    , getSummary
    , modelForEdit
    , modelForEditToCotonomatize
    , modelForNew
    , setCotoSaveError
    , update
    , view
    )

import App.Commands
import App.I18n.Keys as I18nKeys
import App.Markdown
import App.Messages as AppMsg exposing (Msg(CloseModal))
import App.Modals.EditorModalMsg as EditorModalMsg exposing (Msg(..))
import App.Server.Coto
import App.Server.Cotonoma
import App.Server.Graph
import App.Server.Post
import App.Submodels.Context exposing (Context)
import App.Submodels.CotoSelection
import App.Submodels.LocalCotos exposing (LocalCotos)
import App.Types.Connection
import App.Types.Coto exposing (Coto, CotoContent)
import App.Types.Post exposing (Post)
import App.Types.Timeline
import App.Update.Post
import App.Views.Coto
import App.Views.Flow
import Exts.Maybe exposing (isJust)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on, onCheck, onClick, onInput)
import Http exposing (Error(..))
import Json.Decode as Decode
import Utils.HtmlUtil exposing (faIcon, materialIcon)
import Utils.Keyboard.Event exposing (KeyboardEvent)
import Utils.Keyboard.Key
import Utils.Modal as Modal
import Utils.StringUtil exposing (isBlank, isNotBlank)
import Utils.UpdateUtil exposing (..)


type Mode
    = NewCoto (Maybe Coto)
    | NewCotonoma
    | Edit Coto


type RequestStatus
    = None
    | Conflict
    | Rejected


type alias Model =
    { mode : Mode
    , summary : String
    , content : String
    , shareCotonoma : Bool
    , preview : Bool
    , requestProcessing : Bool
    , requestStatus : RequestStatus
    , editingToCotonomatize : Bool
    }


defaultModel : Model
defaultModel =
    { mode = NewCoto Nothing
    , summary = ""
    , content = ""
    , shareCotonoma = False
    , preview = False
    , requestProcessing = False
    , requestStatus = None
    , editingToCotonomatize = False
    }


modelForNew : Context context -> Maybe Coto -> Model
modelForNew context source =
    { defaultModel
        | mode = NewCoto source
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
        |> (\model -> { model | editingToCotonomatize = True })


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
        |> (\model ->
                { model
                    | preview = False
                    , requestProcessing = False
                }
           )



--
-- view
--


view : Context context -> Model -> Html AppMsg.Msg
view context model =
    (case model.mode of
        Edit coto ->
            if isJust coto.asCotonoma then
                cotonomaEditorConfig context model

            else
                cotoEditorConfig context model

        NewCoto _ ->
            cotoEditorConfig context model

        NewCotonoma ->
            cotonomaEditorConfig context model
    )
        |> Modal.view "editor-modal"



-- Coto Editor


cotoEditorConfig : Context context -> Model -> Modal.Config AppMsg.Msg
cotoEditorConfig context model =
    { closeMessage = CloseModal
    , title =
        case model.mode of
            Edit coto ->
                button
                    [ class "edit-coto", disabled True ]
                    [ text (context.i18nText I18nKeys.Coto) ]

            _ ->
                newEditorTitle context model
    , content =
        div [ class "coto-editor-modal-body" ]
            [ targetCotonomaDiv context model
            , sourceCotoDiv context model
            , cotoEditor context model
            ]
    , buttons =
        [ button
            [ class "button preview"
            , disabled (isBlank model.content || model.requestProcessing)
            , onClick (AppMsg.EditorModalMsg TogglePreview)
            ]
            [ if model.preview then
                text (context.i18nText I18nKeys.EditorModal_Edit)

              else
                text (context.i18nText I18nKeys.EditorModal_Preview)
            ]
        ]
            ++ (case model.mode of
                    Edit coto ->
                        buttonsForEdit context coto model

                    _ ->
                        buttonsForNewCoto context model
               )
    }


cotoEditor : Context context -> Model -> Html AppMsg.Msg
cotoEditor context model =
    div [ class "coto-editor" ]
        [ div [ class "summary-input" ]
            [ adviceOnCotonomaNameDiv context model
            , if model.editingToCotonomatize then
                Utils.HtmlUtil.none

              else
                input
                    [ type_ "text"
                    , class "u-full-width"
                    , placeholder (context.i18nText I18nKeys.EditorModal_Summary)
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
                    , placeholder (context.i18nText I18nKeys.EditorModal_Content)
                    , defaultValue model.content
                    , onInput (AppMsg.EditorModalMsg << EditorInput)
                    , on "keydown" <|
                        Decode.map
                            (AppMsg.EditorModalMsg << EditorKeyDown)
                            Utils.Keyboard.Event.decodeKeyboardEvent
                    ]
                    []
                ]
        , errorDiv context model
        ]



-- Cotonoma Editor


cotonomaEditorConfig : Context context -> Model -> Modal.Config AppMsg.Msg
cotonomaEditorConfig context model =
    { closeMessage = CloseModal
    , title =
        case model.mode of
            Edit coto ->
                button
                    [ class "edit-cotonoma", disabled True ]
                    [ text (context.i18nText I18nKeys.Cotonoma) ]

            _ ->
                newEditorTitle context model
    , content =
        div []
            [ targetCotonomaDiv context model
            , sourceCotoDiv context model
            , cotonomaEditor context model
            ]
    , buttons =
        case model.mode of
            Edit coto ->
                buttonsForEdit context coto model

            _ ->
                buttonsForNewCotonoma context model
    }


cotonomaEditor : Context context -> Model -> Html AppMsg.Msg
cotonomaEditor context model =
    div [ class "cotonoma-editor" ]
        [ case model.mode of
            NewCotonoma ->
                div [ class "cotonoma-help" ]
                    [ text (context.i18nText I18nKeys.EditorModal_CotonomaHelp) ]

            _ ->
                Utils.HtmlUtil.none
        , div [ class "name-input" ]
            [ input
                [ type_ "text"
                , class "u-full-width"
                , placeholder (context.i18nText I18nKeys.EditorModal_CotonomaName)
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
                            [ text (context.i18nText I18nKeys.EditorModal_ShareCotonoma) ]
                        , span [ class "note" ]
                            [ text (" (" ++ context.i18nText I18nKeys.EditorModal_ShareCotonomaNote ++ ")") ]
                        ]
                    ]
                ]
            ]
        , errorDiv context model
        ]



-- Partials


newEditorTitle : Context context -> Model -> Html AppMsg.Msg
newEditorTitle context model =
    (case model.mode of
        NewCoto source ->
            if isJust source then
                [ button
                    [ class "sub-coto", disabled True ]
                    [ text (context.i18nText I18nKeys.Coto) ]
                ]

            else
                [ button
                    [ class "coto", disabled True ]
                    [ text (context.i18nText I18nKeys.Coto) ]
                , button
                    [ class "cotonoma"
                    , onClick (AppMsg.EditorModalMsg SetNewCotonomaMode)
                    ]
                    [ text (context.i18nText I18nKeys.Cotonoma) ]
                ]

        NewCotonoma ->
            [ button
                [ class "coto"
                , onClick (AppMsg.EditorModalMsg SetNewCotoMode)
                ]
                [ text (context.i18nText I18nKeys.Coto) ]
            , button
                [ class "cotonoma", disabled True ]
                [ text (context.i18nText I18nKeys.Cotonoma) ]
            ]

        _ ->
            []
    )
        |> div []


targetCotonomaDiv : Context context -> Model -> Html AppMsg.Msg
targetCotonomaDiv context model =
    case model.mode of
        Edit _ ->
            Utils.HtmlUtil.none

        _ ->
            div [ class "posting-to" ]
                (context.cotonoma
                    |> Maybe.map
                        (\cotonoma ->
                            [ App.Views.Coto.cotonomaLabel cotonoma.owner cotonoma ]
                        )
                    |> Maybe.withDefault
                        [ materialIcon "home" Nothing
                        , text (context.i18nText I18nKeys.MyHome)
                        ]
                )


sourceCotoDiv : Context context -> Model -> Html AppMsg.Msg
sourceCotoDiv context model =
    case model.mode of
        NewCoto (Just source) ->
            div [ class "source-coto" ]
                [ App.Views.Coto.bodyDiv
                    context
                    Nothing
                    "source-coto"
                    App.Markdown.markdown
                    source
                , div [ class "arrow" ]
                    [ materialIcon "arrow_downward" Nothing ]
                ]

        _ ->
            Utils.HtmlUtil.none


buttonsForNewCoto : Context context -> Model -> List (Html AppMsg.Msg)
buttonsForNewCoto context model =
    [ if
        App.Submodels.CotoSelection.anySelection context
            && (model.mode == NewCoto Nothing)
      then
        button
            [ class "button connect"
            , disabled (isBlank model.content || model.requestProcessing)
            , onClick
                (AppMsg.OpenConnectModalByNewPost
                    (CotoContent model.content (getSummary model))
                    AppMsg.NoOp
                )
            ]
            [ faIcon "link" Nothing
            , span [ class "shortcut-help" ] [ text "(Alt + Enter)" ]
            ]

      else
        Utils.HtmlUtil.none
    , button
        [ class "button button-primary"
        , disabled (isBlank model.content || model.requestProcessing)
        , onClick (AppMsg.EditorModalMsg EditorModalMsg.Post)
        ]
        (if model.requestProcessing then
            [ text (context.i18nText I18nKeys.Posting ++ "...") ]

         else
            [ text (context.i18nText I18nKeys.Post)
            , span [ class "shortcut-help" ] [ text "(Ctrl + Enter)" ]
            ]
        )
    ]


buttonsForNewCotonoma : Context context -> Model -> List (Html AppMsg.Msg)
buttonsForNewCotonoma context model =
    [ button
        [ class "button button-primary"
        , disabled (isBlank model.content || model.requestProcessing)
        , onClick (AppMsg.EditorModalMsg PostCotonoma)
        ]
        (if model.requestProcessing then
            [ text (context.i18nText I18nKeys.Posting ++ "...") ]

         else
            [ text (context.i18nText I18nKeys.Post) ]
        )
    ]


buttonsForEdit : Context context -> Coto -> Model -> List (Html AppMsg.Msg)
buttonsForEdit context coto model =
    [ button
        [ class "button button-primary"
        , disabled (isBlank model.content || model.requestProcessing)
        , onClick (AppMsg.EditorModalMsg Save)
        ]
        (if model.requestProcessing then
            [ text (context.i18nText I18nKeys.Saving ++ "...") ]

         else
            [ text (context.i18nText I18nKeys.Save)
            , if isJust coto.asCotonoma then
                Utils.HtmlUtil.none

              else
                span [ class "shortcut-help" ] [ text "(Ctrl + Enter)" ]
            ]
        )
    ]


errorDiv : Context context -> Model -> Html AppMsg.Msg
errorDiv context model =
    case model.requestStatus of
        Conflict ->
            div [ class "error" ]
                [ span [ class "message" ]
                    [ text (context.i18nText I18nKeys.EditorModal_DuplicateCotonomaName) ]
                ]

        Rejected ->
            div [ class "error" ]
                [ span [ class "message" ]
                    [ text (context.i18nText I18nKeys.UnexpectedErrorOccurred) ]
                ]

        _ ->
            Utils.HtmlUtil.none


adviceOnCotonomaNameDiv : Context context -> Model -> Html AppMsg.Msg
adviceOnCotonomaNameDiv context model =
    if model.editingToCotonomatize then
        let
            contentLength =
                String.length model.content

            maxlength =
                App.Types.Coto.cotonomaNameMaxlength
        in
        div [ class "advice-on-cotonoma-name" ]
            [ text
                (context.i18nText
                    (I18nKeys.EditorModal_TooLongForCotonomaName maxlength)
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
        Utils.HtmlUtil.none



--
-- update
--


type alias UpdateModel model =
    LocalCotos { model | editorModal : Model }


update : Context context -> EditorModalMsg.Msg -> UpdateModel model -> ( UpdateModel model, Cmd AppMsg.Msg )
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

        PostedAndSubordinateToCoto postId coto (Ok post) ->
            model
                |> App.Update.Post.onPosted context postId post
                |> chain (subordinatePostToCoto context coto post)
                |> addCmd (\_ -> App.Commands.sendMsg AppMsg.ClearModals)

        PostedAndSubordinateToCoto postId coto (Err _) ->
            model |> withoutCmd

        PostCotonoma ->
            { model | editorModal = { editorModal | requestProcessing = True } }
                |> postCotonoma context

        CotonomaPosted postId (Ok post) ->
            { model | cotonomasLoading = True }
                |> App.Update.Post.onPosted context postId post
                |> addCmd (\_ -> App.Commands.sendMsg AppMsg.ClearModals)
                |> addCmd (\_ -> App.Server.Cotonoma.refreshCotonomaList context)

        CotonomaPosted postId (Err error) ->
            { model
                | editorModal = setCotoSaveError error editorModal
                , timeline = App.Types.Timeline.deletePendingPost postId timeline
            }
                |> withoutCmd

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
                                    (CotoContent
                                        model.editorModal.content
                                        (Just model.editorModal.summary)
                                    )

                            _ ->
                                Cmd.none
                    )

        SetNewCotoMode ->
            { model | editorModal = { editorModal | mode = NewCoto Nothing } }
                |> withoutCmd

        SetNewCotonomaMode ->
            { model | editorModal = { editorModal | mode = NewCotonoma } }
                |> withoutCmd


post : Context context -> UpdateModel model -> ( UpdateModel model, Cmd AppMsg.Msg )
post context ({ editorModal } as model) =
    let
        content =
            CotoContent editorModal.content (getSummary editorModal)
    in
    case editorModal.mode of
        NewCoto (Just source) ->
            postSubcoto context source content model

        NewCoto Nothing ->
            App.Views.Flow.post context content model

        _ ->
            ( model, Cmd.none )


postSubcoto :
    Context context
    -> Coto
    -> CotoContent
    -> UpdateModel model
    -> ( UpdateModel model, Cmd AppMsg.Msg )
postSubcoto context coto content model =
    let
        ( timeline, newPost ) =
            model.timeline
                |> App.Types.Timeline.post context False content
    in
    { model | timeline = timeline }
        ! [ App.Commands.scrollTimelineToBottom (\_ -> AppMsg.NoOp)
          , App.Server.Post.post
                context.clientId
                context.cotonoma
                (AppMsg.EditorModalMsg
                    << PostedAndSubordinateToCoto timeline.postIdCounter coto
                )
                newPost
          ]


subordinatePostToCoto :
    Context context
    -> Coto
    -> Post
    -> UpdateModel model
    -> ( UpdateModel model, Cmd AppMsg.Msg )
subordinatePostToCoto { clientId, session } coto post model =
    post.cotoId
        |> Maybe.andThen (\cotoId -> App.Submodels.LocalCotos.getCoto cotoId model)
        |> Maybe.map
            (\postCoto ->
                ( App.Submodels.LocalCotos.connect
                    session
                    postCoto
                    [ coto ]
                    App.Types.Connection.Inbound
                    Nothing
                    model
                , App.Server.Graph.connect
                    clientId
                    (Maybe.map .key model.cotonoma)
                    postCoto.id
                    [ coto.id ]
                    App.Types.Connection.Inbound
                    Nothing
                )
            )
        |> Maybe.withDefault ( model, Cmd.none )


handleShortcut :
    Context context
    -> KeyboardEvent
    -> UpdateModel model
    -> ( UpdateModel model, Cmd AppMsg.Msg )
handleShortcut context keyboardEvent model =
    if
        (keyboardEvent.keyCode == Utils.Keyboard.Key.Enter)
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
                        (CotoContent
                            model.editorModal.content
                            (Just model.editorModal.summary)
                        )
                    )

                else
                    ( model, Cmd.none )

            _ ->
                if keyboardEvent.ctrlKey || keyboardEvent.metaKey then
                    post context model

                else if
                    keyboardEvent.altKey
                        && App.Submodels.CotoSelection.anySelection context
                then
                    ( model
                    , App.Commands.sendMsg
                        (AppMsg.OpenConnectModalByNewPost
                            (CotoContent
                                model.editorModal.content
                                (getSummary model.editorModal)
                            )
                            AppMsg.NoOp
                        )
                    )

                else
                    ( model, Cmd.none )

    else
        ( model, Cmd.none )


postCotonoma : Context context -> UpdateModel model -> ( UpdateModel model, Cmd AppMsg.Msg )
postCotonoma context model =
    let
        cotonomaName =
            model.editorModal.content

        ( timeline, _ ) =
            App.Types.Timeline.post
                context
                True
                (CotoContent cotonomaName Nothing)
                model.timeline
    in
    { model | timeline = timeline }
        ! [ App.Commands.scrollTimelineToBottom (\_ -> AppMsg.NoOp)
          , App.Server.Post.postCotonoma
                context.clientId
                context.cotonoma
                (AppMsg.EditorModalMsg
                    << CotonomaPosted timeline.postIdCounter
                )
                model.editorModal.shareCotonoma
                cotonomaName
          ]
