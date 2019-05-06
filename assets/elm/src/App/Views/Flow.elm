module App.Views.Flow exposing
    ( Model
    , defaultModel
    , initScrollPos
    , openOrCloseEditor
    , post
    , setFilter
    , update
    , view
    )

import App.Commands
import App.I18n.Keys as I18nKeys
import App.Messages as AppMsg exposing (..)
import App.Server.Post
import App.Submodels.Context exposing (Context)
import App.Submodels.CotoSelection
import App.Submodels.LocalCotos exposing (LocalCotos)
import App.Types.Coto exposing (CotoContent, Cotonoma)
import App.Types.Post exposing (Post, toCoto)
import App.Types.Session exposing (Session)
import App.Types.Timeline exposing (Timeline)
import App.Types.TimelineFilter exposing (TimelineFilter)
import App.Update.Post
import App.Update.Watch
import App.Views.Amishi
import App.Views.FlowMsg as FlowMsg exposing (Msg(..), TimelineView(..))
import App.Views.Post
import Date
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Keyed
import Json.Decode as Decode
import List.Extra exposing (groupWhile)
import Utils.DateUtil exposing (formatDay, sameDay)
import Utils.EventUtil
    exposing
        ( ScrollPos
        , onClickWithoutPropagation
        , onKeyDown
        , onLinkButtonClick
        , onScroll
        )
import Utils.HtmlUtil exposing (faIcon, materialIcon)
import Utils.Keyboard.Event exposing (KeyboardEvent)
import Utils.Keyboard.Key
import Utils.StringUtil exposing (isBlank, isNotBlank)
import Utils.UpdateUtil exposing (..)


type alias Model =
    { view : TimelineView
    , filter : TimelineFilter
    , random : Bool
    , editorOpen : Bool
    , editorContent : String
    , editorCounter : Int
    }


defaultModel : Model
defaultModel =
    { view = StreamView
    , filter = App.Types.TimelineFilter.defaultTimelineFilter
    , random = False
    , editorOpen = False
    , editorContent = ""
    , editorCounter = 0
    }


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
            Utils.HtmlUtil.none
        , toolbarDiv context model.timeline model.flowView
        , timelineDiv context model
        , postEditor context session model.flowView
        , newCotoButton context model.flowView
        ]


toolbarDiv : Context context -> Timeline -> Model -> Html AppMsg.Msg
toolbarDiv context timeline model =
    div [ class "flow-toolbar" ]
        [ div [ class "tools" ]
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
            , if model.view == TileView then
                span [ class "random" ]
                    [ a
                        [ classList
                            [ ( "tool-button", True )
                            , ( "random", True )
                            , ( "disabled", timeline.loading )
                            ]
                        , title (context.i18nText I18nKeys.Flow_Random)
                        , onClick (AppMsg.FlowMsg Random)
                        ]
                        [ faIcon "random" Nothing ]
                    ]

              else
                Utils.HtmlUtil.none
            ]
        ]


timelineDiv : Context context -> ViewModel model -> Html AppMsg.Msg
timelineDiv context model =
    div
        [ id "timeline"
        , classList
            [ ( "timeline", True )
            , ( "exclude-pinned-graph", model.flowView.filter.excludePinnedGraph )
            ]
        , onScroll (AppMsg.FlowMsg << Scroll)
        ]
        [ moreButton model.timeline
        , case model.flowView.view of
            StreamView ->
                postsAsStream context model.timeline.posts

            TileView ->
                postsAsTiles context model.timeline.posts
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


postsAsStream : Context context -> List Post -> Html AppMsg.Msg
postsAsStream context posts =
    posts
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
                    , Html.Keyed.node
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
                            postsOnDay
                        )
                    ]
                )
            )
        |> Html.Keyed.node "div" [ class "posts-as-stream" ]


postsAsTiles : Context context -> List Post -> Html AppMsg.Msg
postsAsTiles context posts =
    div [ class "posts-as-tiles" ]
        [ posts
            |> List.reverse
            |> List.map
                (\post ->
                    ( getKey post
                    , App.Views.Post.view context post
                    )
                )
            |> Html.Keyed.node "div" [ class "posts" ]
        ]


unreadStartLine : Context context -> Post -> Html AppMsg.Msg
unreadStartLine context post =
    let
        postTimestamp =
            Maybe.map Date.toTime post.postedAt

        lastPostTimestamp =
            Maybe.andThen .lastPostTimestamp context.cotonoma
    in
    Maybe.map3
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
            [ App.Views.Amishi.inline [ "session" ] session.amishi
            , div [ class "tool-buttons" ]
                [ if List.isEmpty context.selection then
                    Utils.HtmlUtil.none

                  else
                    span [ class "connect-buttons" ]
                        [ button
                            [ class "button connect"
                            , disabled (isBlank model.editorContent)
                            , onMouseDown
                                (AppMsg.OpenConnectModalByNewPost
                                    (CotoContent model.editorContent Nothing)
                                    (AppMsg.FlowMsg PostedByConnectModal)
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
        , hidden model.editorOpen
        , onClick OpenNewEditorModal
        ]
        [ materialIcon "create" Nothing
        , span [ class "shortcut" ]
            [ text ("(" ++ context.i18nText I18nKeys.Flow_ShortcutToOpenEditor ++ ")") ]
        ]


type alias UpdateModel model =
    LocalCotos { model | flowView : Model }


update : Context context -> FlowMsg.Msg -> UpdateModel model -> ( UpdateModel model, Cmd AppMsg.Msg )
update context msg ({ flowView, timeline } as model) =
    case msg of
        TimelineScrollPosInitialized scrollTop ->
            { model
                | timeline = App.Types.Timeline.setScrollPosInitialized timeline
                , flowView = { flowView | random = False }
            }
                |> (\model ->
                        if scrollTop == 0 then
                            -- Clear unread because there's no scrollbar
                            App.Update.Watch.clearUnread context model

                        else
                            ( model, Cmd.none )
                   )

        ImageLoaded ->
            model
                |> withCmdIf
                    (\model -> model.timeline.pageIndex == 0 && not model.flowView.random)
                    (\_ -> App.Commands.scrollTimelineToBottom (\_ -> NoOp))

        SwitchView view ->
            if model.flowView.random then
                { model | flowView = switchView view flowView }
                    |> reloadRecentPosts context

            else
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
                |> addCmd (\_ -> App.Commands.focus NoOp "quick-coto-input")

        Post ->
            postFromQuickEditor context (CotoContent flowView.editorContent Nothing) model
                |> addCmd (\_ -> App.Commands.focus NoOp "quick-coto-input")

        Posted postId (Ok post) ->
            model
                |> App.Update.Post.onPosted context postId post
                |> addCmd (\_ -> App.Commands.sendMsg AppMsg.ClearModals)

        Posted postId (Err _) ->
            model |> withoutCmd

        PostedByConnectModal ->
            { model | flowView = clearEditorContent model.flowView }
                |> withoutCmd

        Scroll scrollPos ->
            if isScrolledToBottom scrollPos then
                App.Update.Watch.clearUnread context model

            else
                model |> withoutCmd

        Random ->
            ( { model | timeline = App.Types.Timeline.setLoading timeline }
            , App.Server.Post.fetchRandomPosts
                (AppMsg.FlowMsg << RandomPostsFetched)
                flowView.filter
                (Maybe.map .key context.cotonoma)
            )

        RandomPostsFetched (Ok posts) ->
            ( { model
                | flowView = { flowView | random = True }
                , timeline = App.Types.Timeline.setPosts posts timeline
              }
            , App.Commands.scrollTimelineToTop NoOp
            )

        RandomPostsFetched (Err _) ->
            model |> withoutCmd


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
                && App.Submodels.CotoSelection.anySelection context
        then
            ( model
            , App.Commands.sendMsg
                (AppMsg.OpenConnectModalByNewPost
                    content
                    (AppMsg.FlowMsg PostedByConnectModal)
                )
            )

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
            (AppMsg.FlowMsg << Posted newTimeline.postIdCounter)
            newPost
        ]
    )


isScrolledToBottom : ScrollPos -> Bool
isScrolledToBottom { scrollTop, contentHeight, containerHeight } =
    (contentHeight - containerHeight - scrollTop)
        --|> Debug.log "scrollPosFromBottom: "
        |> (\scrollPosFromBottom -> scrollPosFromBottom < 30)


reloadRecentPosts : Context context -> UpdateModel model -> ( UpdateModel model, Cmd AppMsg.Msg )
reloadRecentPosts context ({ flowView, timeline } as model) =
    { model
        | timeline = App.Types.Timeline.setInitializing timeline
        , flowView = { flowView | random = False }
    }
        |> withCmd
            (\model ->
                context.cotonoma
                    |> Maybe.map .key
                    |> Maybe.map (App.Server.Post.fetchCotonomaPosts 0 model.flowView.filter)
                    |> Maybe.withDefault (App.Server.Post.fetchHomePosts 0 model.flowView.filter)
            )
