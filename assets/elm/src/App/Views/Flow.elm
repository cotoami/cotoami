module App.Views.Flow
    exposing
        ( Model
        , defaultModel
        , setFilter
        , openOrCloseEditor
        , update
        , initScrollPos
        , post
        , view
        )

import Date
import Html exposing (..)
import Html.Keyed
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode
import List.Extra exposing (groupWhile)
import Utils.UpdateUtil exposing (..)
import Utils.StringUtil exposing (isBlank, isNotBlank)
import Utils.HtmlUtil exposing (faIcon, materialIcon)
import Utils.DateUtil exposing (sameDay, formatDay)
import Utils.EventUtil
    exposing
        ( onKeyDown
        , onClickWithoutPropagation
        , onLinkButtonClick
        , ScrollPos
        , onScroll
        )
import Utils.Keyboard.Key
import Utils.Keyboard.Event exposing (KeyboardEvent)
import App.I18n.Keys as I18nKeys
import App.Types.Coto exposing (CotoContent, Cotonoma)
import App.Types.Post exposing (Post, toCoto)
import App.Types.Session exposing (Session)
import App.Types.Timeline exposing (Timeline)
import App.Types.TimelineFilter exposing (TimelineFilter)
import App.Types.Watch exposing (Watch)
import App.Submodels.Context exposing (Context)
import App.Submodels.Modals exposing (Modals)
import App.Submodels.LocalCotos exposing (LocalCotos)
import App.Messages as AppMsg exposing (..)
import App.Views.FlowMsg as FlowMsg exposing (Msg(..), TimelineView(..))
import App.Views.Post
import App.Modals.ConnectModal exposing (WithConnectModal)
import App.Commands
import App.Server.Post
import App.Server.Watch
import App.Ports.App


type alias Model =
    { hidden : Bool
    , view : TimelineView
    , filter : TimelineFilter
    , editorOpen : Bool
    , editorContent : String
    , editorCounter : Int
    }


defaultModel : Model
defaultModel =
    { hidden = False
    , view = StreamView
    , filter = App.Types.TimelineFilter.defaultTimelineFilter
    , editorOpen = False
    , editorContent = ""
    , editorCounter = 0
    }


toggle : Model -> Model
toggle model =
    { model | hidden = not model.hidden }


switchView : TimelineView -> Model -> Model
switchView view model =
    { model | view = view }


setFilter : TimelineFilter -> Model -> Model
setFilter filter model =
    { model | filter = filter }


openOrCloseEditor : Bool -> Model -> Model
openOrCloseEditor open model =
    { model | editorOpen = open }


setEditorContent : String -> Model -> Model
setEditorContent content model =
    { model | editorContent = content }


clearEditorContent : Model -> Model
clearEditorContent model =
    { model
        | editorContent = ""
        , editorCounter = model.editorCounter + 1
    }


type alias UpdateModel model =
    LocalCotos
        (Modals
            (WithConnectModal
                { model
                    | flowView : Model
                }
            )
        )


update : Context context -> FlowMsg.Msg -> UpdateModel model -> ( UpdateModel model, Cmd AppMsg.Msg )
update context msg ({ flowView, timeline } as model) =
    case msg of
        ToggleFlow ->
            { model | flowView = toggle flowView }
                |> withoutCmd

        TimelineScrollPosInitialized scrollTop ->
            { model | timeline = App.Types.Timeline.setScrollPosInitialized timeline }
                |> (\model ->
                        if scrollTop == 0 then
                            -- Clear unread because there's no scrollbar
                            clearUnreadInCurrentCotonoma context model
                        else
                            ( model, Cmd.none )
                   )

        ImageLoaded ->
            model
                |> withCmdIf
                    (\model -> model.timeline.pageIndex == 0)
                    (\_ -> App.Commands.scrollTimelineToBottom (\_ -> NoOp))

        SwitchView view ->
            { model | flowView = switchView view flowView }
                |> withoutCmd

        LoadMorePosts ->
            { model | timeline = App.Types.Timeline.setLoadingMore timeline }
                |> withCmd
                    (\model ->
                        App.Server.Post.fetchPostsByContext
                            (App.Types.Timeline.nextPageIndex timeline)
                            flowView.filter
                            context
                    )

        EditorFocus ->
            { model | flowView = openOrCloseEditor True flowView }
                |> withCmdIf
                    (\model -> flowView.editorOpen)
                    (\_ -> App.Commands.scrollTimelineByQuickEditorOpen NoOp)

        EditorInput content ->
            { model | flowView = setEditorContent content flowView }
                |> withoutCmd

        EditorKeyDown keyboardEvent ->
            handleEditorShortcut context keyboardEvent (CotoContent flowView.editorContent Nothing) model
                |> addCmd (\_ -> App.Commands.focus "quick-coto-input" NoOp)

        Post ->
            postFromQuickEditor context (CotoContent flowView.editorContent Nothing) model
                |> addCmd (\_ -> App.Commands.focus "quick-coto-input" NoOp)

        Posted postId (Ok response) ->
            { model | timeline = App.Types.Timeline.setCotoSaved postId response timeline }
                |> App.Submodels.LocalCotos.updateCotonomaMaybe response.postedIn
                |> App.Submodels.Modals.clearModals
                |> withoutCmd

        Posted postId (Err _) ->
            model |> withoutCmd

        ConfirmPostAndConnect content ->
            App.Modals.ConnectModal.openWithPost content model

        Scroll scrollPos ->
            if isScrolledToBottom scrollPos then
                clearUnreadInCurrentCotonoma context model
            else
                model |> withoutCmd

        WatchTimestampUpdated _ ->
            model |> withCmd (\_ -> App.Ports.App.updateUnreadStateInTitle context)


initScrollPos : LocalCotos a -> Cmd AppMsg.Msg
initScrollPos localCotos =
    if App.Submodels.LocalCotos.areTimelineAndGraphLoaded localCotos then
        App.Commands.scrollTimelineToBottom
            (AppMsg.FlowMsg << TimelineScrollPosInitialized)
    else
        Cmd.none


handleEditorShortcut :
    Context context
    -> KeyboardEvent
    -> CotoContent
    -> UpdateModel model
    -> ( UpdateModel model, Cmd AppMsg.Msg )
handleEditorShortcut context keyboardEvent content model =
    if
        (keyboardEvent.keyCode == Utils.Keyboard.Key.Enter)
            && isNotBlank content.content
    then
        if keyboardEvent.ctrlKey || keyboardEvent.metaKey then
            postFromQuickEditor context content model
        else if
            keyboardEvent.altKey
                && App.Submodels.Context.anySelection context
        then
            App.Modals.ConnectModal.openWithPost content model
        else
            ( model, Cmd.none )
    else
        ( model, Cmd.none )


postFromQuickEditor :
    Context context
    -> CotoContent
    -> UpdateModel model
    -> ( UpdateModel model, Cmd AppMsg.Msg )
postFromQuickEditor context content model =
    { model | flowView = clearEditorContent model.flowView }
        |> post context content


post : Context context -> CotoContent -> LocalCotos model -> ( LocalCotos model, Cmd AppMsg.Msg )
post context content model =
    let
        ( newTimeline, newPost ) =
            App.Types.Timeline.post context False content model.timeline
    in
        ( { model | timeline = newTimeline }
        , Cmd.batch
            [ App.Commands.scrollTimelineToBottom (\_ -> NoOp)
            , App.Server.Post.post
                context.clientId
                context.cotonoma
                (AppMsg.FlowMsg << (Posted newTimeline.postIdCounter))
                newPost
            ]
        )


clearUnreadInCurrentCotonoma :
    Context context
    -> LocalCotos model
    -> ( LocalCotos model, Cmd AppMsg.Msg )
clearUnreadInCurrentCotonoma context model =
    (Maybe.map2
        (\cotonoma latestPost ->
            model.watchlist
                |> App.Types.Watch.findWatchByCotonomaId cotonoma.id
                |> Maybe.map (\watch -> updateWatchTimestamp context latestPost watch model)
                |> Maybe.withDefault ( model, Cmd.none )
        )
        model.cotonoma
        (App.Types.Timeline.latestPost model.timeline)
    )
        |> Maybe.withDefault ( model, Cmd.none )


updateWatchTimestamp :
    Context context
    -> Post
    -> Watch
    -> LocalCotos model
    -> ( LocalCotos model, Cmd AppMsg.Msg )
updateWatchTimestamp context post watch model =
    let
        postTimestamp =
            Maybe.map Date.toTime post.postedAt

        isNewPost =
            (Maybe.map2
                (\watch post -> watch < post)
                watch.lastPostTimestamp
                postTimestamp
            )
                |> Maybe.withDefault
                    (watch.lastPostTimestamp /= postTimestamp)
    in
        if isNewPost then
            model.watchlist
                |> List.Extra.updateIf
                    (\w -> w.cotonoma.id == watch.cotonoma.id)
                    (\w -> { w | lastPostTimestamp = postTimestamp })
                |> (\watchlist -> { model | watchlist = watchlist })
                |> withCmd
                    (\_ ->
                        postTimestamp
                            |> Maybe.map
                                (App.Server.Watch.updateLastPostTimestamp
                                    (AppMsg.FlowMsg << WatchTimestampUpdated)
                                    context.clientId
                                    watch.cotonoma.key
                                )
                            |> Maybe.withDefault Cmd.none
                    )
        else
            ( model, Cmd.none )


isScrolledToBottom : ScrollPos -> Bool
isScrolledToBottom { scrollTop, contentHeight, containerHeight } =
    (contentHeight - containerHeight - scrollTop)
        --|> Debug.log "scrollPosFromBottom: "
        |> (\scrollPosFromBottom -> scrollPosFromBottom < 30)


type alias ViewModel model =
    LocalCotos
        { model
            | flowView : Model
        }


view : Context context -> Session -> ViewModel model -> Html AppMsg.Msg
view context session model =
    div
        [ id "flow"
        , classList
            [ ( "editing", model.flowView.editorOpen )
            ]
        ]
        [ if not (App.Submodels.LocalCotos.isTimelineReady model) then
            div [ class "loading-overlay" ] []
          else
            div [] []
        , toolbarDiv context model.flowView
        , timelineDiv context model
        , postEditor context session model.flowView
        , newCotoButton context model.flowView
        ]


toolbarDiv : Context context -> Model -> Html AppMsg.Msg
toolbarDiv context model =
    div [ class "flow-toolbar" ]
        [ a
            [ class "tool-button flow-toggle"
            , title (context.i18nText I18nKeys.Flow_HideFlow)
            , onLinkButtonClick (AppMsg.FlowMsg ToggleFlow)
            ]
            [ materialIcon "arrow_left" Nothing ]
        , div [ class "tools" ]
            [ a
                [ classList
                    [ ( "tool-button", True )
                    , ( "open-filter", True )
                    ]
                , title (context.i18nText I18nKeys.Flow_Filter)
                , onClick OpenTimelineFilterModal
                ]
                [ materialIcon "filter_list" Nothing ]
            , span [ class "view-switch" ]
                [ a
                    [ classList
                        [ ( "tool-button", True )
                        , ( "stream-view", True )
                        , ( "disabled", model.view == StreamView )
                        ]
                    , title (context.i18nText I18nKeys.Flow_StreamView)
                    , onClick (AppMsg.FlowMsg (SwitchView StreamView))
                    ]
                    [ materialIcon "view_stream" Nothing ]
                , a
                    [ classList
                        [ ( "tool-button", True )
                        , ( "tile-view", True )
                        , ( "disabled", model.view == TileView )
                        ]
                    , title (context.i18nText I18nKeys.Flow_TileView)
                    , onClick (AppMsg.FlowMsg (SwitchView TileView))
                    ]
                    [ materialIcon "view_module" Nothing ]
                ]
            ]
        ]


timelineDiv : Context context -> ViewModel model -> Html AppMsg.Msg
timelineDiv context model =
    div
        [ id "timeline"
        , classList
            [ ( "timeline", True )
            , ( "stream", model.flowView.view == StreamView )
            , ( "tile", model.flowView.view == TileView )
            , ( "exclude-pinned-graph", model.flowView.filter.excludePinnedGraph )
            ]
        , onScroll (AppMsg.FlowMsg << Scroll)
        ]
        [ moreButton model.timeline
        , model.timeline.posts
            |> List.reverse
            |> groupWhile (\p1 p2 -> sameDay p1.postedAt p2.postedAt)
            |> List.map
                (\postsOnDay ->
                    let
                        lang =
                            context.session
                                |> Maybe.map (\session -> session.lang)
                                |> Maybe.withDefault ""

                        postDateString =
                            List.head postsOnDay
                                |> Maybe.andThen (\post -> post.postedAt)
                                |> Maybe.map (formatDay lang)
                                |> Maybe.withDefault ""
                    in
                        ( postDateString
                        , div
                            [ class "posts-on-day" ]
                            [ div
                                [ class "date-header" ]
                                [ span [ class "date" ] [ text postDateString ] ]
                            , postsDiv context postsOnDay
                            ]
                        )
                )
            |> Html.Keyed.node "div" [ class "posts" ]
        ]


moreButton : Timeline -> Html AppMsg.Msg
moreButton timeline =
    if timeline.more then
        div [ class "more-button-div" ]
            [ if timeline.loadingMore then
                button
                    [ class "button more-button loading", disabled True ]
                    [ img [ src "/images/loading-horizontal.gif" ] [] ]
              else
                button
                    [ class "button more-button"
                    , onClick (AppMsg.FlowMsg LoadMorePosts)
                    ]
                    [ materialIcon "arrow_drop_up" Nothing ]
            ]
    else
        Utils.HtmlUtil.none


postsDiv : Context context -> List Post -> Html AppMsg.Msg
postsDiv context posts =
    Html.Keyed.node
        "div"
        [ class "posts" ]
        (List.map
            (\post ->
                ( getKey post
                , div []
                    [ App.Views.Post.view context post
                    , unreadStartLine context post
                    ]
                )
            )
            posts
        )


unreadStartLine : Context context -> Post -> Html AppMsg.Msg
unreadStartLine context post =
    let
        postTimestamp =
            Maybe.map (Date.toTime) post.postedAt

        lastPostTimestamp =
            Maybe.andThen (.lastPostTimestamp) context.cotonoma
    in
        (Maybe.map3
            (\postTimestamp lastPostTimestamp watch ->
                if
                    (postTimestamp /= lastPostTimestamp)
                        && (watch.lastPostTimestamp == Just postTimestamp)
                then
                    div [ class "unread-start-line" ]
                        [ hr [] []
                        , div [ class "line-label" ]
                            [ text (context.i18nText I18nKeys.Flow_NewPosts) ]
                        ]
                else
                    Utils.HtmlUtil.none
            )
            postTimestamp
            lastPostTimestamp
            context.watchStateOnCotonomaLoad
        )
            |> Maybe.withDefault Utils.HtmlUtil.none


getKey : Post -> String
getKey post =
    post.cotoId
        |> Maybe.map toString
        |> Maybe.withDefault
            (post.postId
                |> Maybe.map toString
                |> Maybe.withDefault ""
            )


postEditor : Context context -> Session -> Model -> Html AppMsg.Msg
postEditor context session model =
    div [ class "quick-coto-editor" ]
        [ div [ class "toolbar", hidden (not model.editorOpen) ]
            [ span [ class "user session" ]
                [ img [ class "avatar", src session.amishi.avatarUrl ] []
                , span [ class "name" ] [ text session.amishi.displayName ]
                ]
            , div [ class "tool-buttons" ]
                [ if List.isEmpty context.selection then
                    Utils.HtmlUtil.none
                  else
                    span [ class "connect-buttons" ]
                        [ button
                            [ class "button connect"
                            , disabled (isBlank model.editorContent)
                            , onMouseDown
                                (AppMsg.FlowMsg
                                    (ConfirmPostAndConnect
                                        (CotoContent model.editorContent Nothing)
                                    )
                                )
                            ]
                            [ faIcon "link" Nothing
                            , span [ class "shortcut-help" ] [ text "(Alt + Enter)" ]
                            ]
                        ]
                , button
                    [ class "button-primary post"
                    , disabled (isBlank model.editorContent)
                    , onMouseDown (AppMsg.FlowMsg FlowMsg.Post)
                    ]
                    [ text (context.i18nText I18nKeys.Post)
                    , span [ class "shortcut-help" ] [ text "(Ctrl + Enter)" ]
                    ]
                ]
            ]
        , Html.Keyed.node
            "div"
            []
            [ ( toString model.editorCounter
              , textarea
                    [ class "coto"
                    , id "quick-coto-input"
                    , placeholder (context.i18nText I18nKeys.Flow_EditorPlaceholder)
                    , defaultValue model.editorContent
                    , onFocus (AppMsg.FlowMsg EditorFocus)
                    , onInput (AppMsg.FlowMsg << EditorInput)
                    , on "keydown" <|
                        Decode.map
                            (AppMsg.FlowMsg << EditorKeyDown)
                            Utils.Keyboard.Event.decodeKeyboardEvent
                    , onClickWithoutPropagation NoOp
                    ]
                    []
              )
            ]
        ]


newCotoButton : Context context -> Model -> Html AppMsg.Msg
newCotoButton context model =
    a
        [ class "tool-button new-coto-button"
        , title "New Coto"
        , hidden (model.editorOpen)
        , onClick OpenNewEditorModal
        ]
        [ materialIcon "create" Nothing
        , span [ class "shortcut" ]
            [ text ("(" ++ (context.i18nText I18nKeys.Flow_ShortcutToOpenEditor) ++ ")") ]
        ]
