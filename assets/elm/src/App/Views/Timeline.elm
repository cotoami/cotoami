module App.Views.Timeline
    exposing
        ( update
        , post
        , view
        )

import Html exposing (..)
import Html.Keyed
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode
import List.Extra exposing (groupWhile)
import Util.StringUtil exposing (isBlank, isNotBlank)
import Util.HtmlUtil exposing (faIcon, materialIcon)
import Util.DateUtil exposing (sameDay, formatDay)
import Util.EventUtil exposing (onKeyDown, onClickWithoutPropagation, onLinkButtonClick)
import Util.UpdateUtil exposing (..)
import Util.Keyboard.Key
import Util.Keyboard.Event exposing (KeyboardEvent)
import App.Types.Post exposing (Post, toCoto)
import App.Types.Session exposing (Session)
import App.Types.Graph exposing (Direction(..), Graph, member)
import App.Types.Timeline exposing (Timeline, TimelineView(..))
import App.Submodels.Context exposing (Context)
import App.Submodels.Modals exposing (Modals)
import App.Submodels.LocalCotos exposing (LocalCotos)
import App.Messages as AppMsg exposing (..)
import App.Views.TimelineMsg as TimelineMsg exposing (Msg(..))
import App.Views.Post
import App.Commands
import App.Server.Post


type alias Model a =
    LocalCotos (Modals a)


update : Context a -> TimelineMsg.Msg -> Model b -> ( Model b, Cmd AppMsg.Msg )
update context msg ({ timeline } as model) =
    case msg of
        SwitchView view ->
            { model | timeline = App.Types.Timeline.switchView view timeline }
                |> withoutCmd

        LoadMorePosts ->
            { model | timeline = App.Types.Timeline.setLoadingMore timeline }
                |> withCmd
                    (\model ->
                        App.Server.Post.fetchPostsByContext
                            (App.Types.Timeline.nextPageIndex timeline)
                            timeline.filter
                            context
                    )

        EditorFocus ->
            { model | timeline = App.Types.Timeline.openOrCloseEditor True timeline }
                |> withCmdIf
                    (\model -> timeline.editorOpen)
                    (\_ -> App.Commands.scrollTimelineByQuickEditorOpen NoOp)

        EditorInput content ->
            { model | timeline = App.Types.Timeline.setEditorContent content timeline }
                |> withoutCmd

        EditorKeyDown keyboardEvent ->
            handleEditorShortcut context keyboardEvent Nothing timeline.editorContent model
                |> addCmd (\_ -> App.Commands.focus "quick-coto-input" NoOp)

        Post ->
            post context Nothing timeline.editorContent timeline
                |> Tuple.mapFirst (\timeline -> { model | timeline = timeline })
                |> addCmd (\_ -> App.Commands.focus "quick-coto-input" NoOp)

        Posted postId (Ok response) ->
            { model | timeline = App.Types.Timeline.setCotoSaved postId response timeline }
                |> App.Submodels.LocalCotos.updateRecentCotonomas response.postedIn
                |> App.Submodels.Modals.clearModals
                |> withoutCmd

        Posted postId (Err _) ->
            model |> withoutCmd

        ConfirmPostAndConnect content summary ->
            App.Submodels.Modals.confirmPostAndConnect summary content model


handleEditorShortcut :
    Context a
    -> KeyboardEvent
    -> Maybe String
    -> String
    -> Model b
    -> ( Model b, Cmd AppMsg.Msg )
handleEditorShortcut context keyboardEvent summary content model =
    if
        (keyboardEvent.keyCode == Util.Keyboard.Key.Enter)
            && isNotBlank content
    then
        if keyboardEvent.ctrlKey || keyboardEvent.metaKey then
            post context summary content model.timeline
                |> Tuple.mapFirst (\timeline -> { model | timeline = timeline })
        else if
            keyboardEvent.altKey
                && App.Submodels.Context.anySelection context
        then
            App.Submodels.Modals.confirmPostAndConnect summary content model
        else
            ( model, Cmd.none )
    else
        ( model, Cmd.none )


post : Context a -> Maybe String -> String -> Timeline -> ( Timeline, Cmd AppMsg.Msg )
post context summary content timeline =
    let
        ( newTimeline, newPost ) =
            App.Types.Timeline.post context False summary content timeline
    in
        ( newTimeline
        , Cmd.batch
            [ App.Commands.scrollTimelineToBottom NoOp
            , App.Server.Post.post
                context.clientId
                context.cotonoma
                (AppMsg.TimelineMsg << (Posted newTimeline.postIdCounter))
                newPost
            ]
        )


view : Context a -> Session -> LocalCotos b -> Html AppMsg.Msg
view context session model =
    div
        [ id "timeline-and-input"
        , classList
            [ ( "editing", model.timeline.editorOpen )
            ]
        ]
        [ if not (App.Submodels.LocalCotos.isTimelineReady model) then
            div [ class "loading-overlay" ] []
          else
            div [] []
        , toolbarDiv context model.timeline
        , timelineDiv context model.graph model.timeline
        , postEditor context session model.timeline
        , newCotoButton model.timeline
        ]


toolbarDiv : Context a -> Timeline -> Html AppMsg.Msg
toolbarDiv context timeline =
    div [ class "timeline-toolbar" ]
        [ a
            [ class "tool-button timeline-toggle"
            , title "Hide timeline"
            , onLinkButtonClick ToggleTimeline
            ]
            [ materialIcon "arrow_left" Nothing ]
        , div [ class "tools" ]
            [ a
                [ classList
                    [ ( "tool-button", True )
                    , ( "open-filter", True )
                    ]
                , title "Filter"
                , onClick OpenTimelineFilterModal
                ]
                [ materialIcon "filter_list" Nothing ]
            , span [ class "view-switch" ]
                [ a
                    [ classList
                        [ ( "tool-button", True )
                        , ( "stream-view", True )
                        , ( "disabled", timeline.view == StreamView )
                        ]
                    , title "Stream View"
                    , onClick (AppMsg.TimelineMsg (SwitchView StreamView))
                    ]
                    [ materialIcon "view_stream" Nothing ]
                , a
                    [ classList
                        [ ( "tool-button", True )
                        , ( "tile-view", True )
                        , ( "disabled", timeline.view == TileView )
                        ]
                    , title "Tile View"
                    , onClick (AppMsg.TimelineMsg (SwitchView TileView))
                    ]
                    [ materialIcon "view_module" Nothing ]
                ]
            ]
        ]


timelineDiv : Context a -> Graph -> Timeline -> Html AppMsg.Msg
timelineDiv context graph model =
    div
        [ id "timeline"
        , classList
            [ ( "timeline", True )
            , ( "stream", model.view == StreamView )
            , ( "tile", model.view == TileView )
            , ( "exclude-pinned-graph", model.filter.excludePinnedGraph )
            ]
        ]
        [ moreButton model
        , model.posts
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
                            , postsDiv context graph postsOnDay
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
                    , onClick (AppMsg.TimelineMsg LoadMorePosts)
                    ]
                    [ materialIcon "arrow_drop_up" Nothing ]
            ]
    else
        Util.HtmlUtil.none


postsDiv : Context a -> Graph -> List Post -> Html AppMsg.Msg
postsDiv context graph posts =
    Html.Keyed.node
        "div"
        [ class "posts" ]
        (List.map
            (\post ->
                ( getKey post
                , App.Views.Post.view context graph post
                )
            )
            posts
        )


getKey : Post -> String
getKey post =
    post.cotoId
        |> Maybe.map toString
        |> Maybe.withDefault
            (post.postId
                |> Maybe.map toString
                |> Maybe.withDefault ""
            )


postEditor : Context a -> Session -> Timeline -> Html AppMsg.Msg
postEditor context session model =
    div [ class "quick-coto-editor" ]
        [ div [ class "toolbar", hidden (not model.editorOpen) ]
            [ span [ class "user session" ]
                [ img [ class "avatar", src session.avatarUrl ] []
                , span [ class "name" ] [ text session.displayName ]
                ]
            , div [ class "tool-buttons" ]
                [ if List.isEmpty context.selection then
                    Util.HtmlUtil.none
                  else
                    span [ class "connect-buttons" ]
                        [ button
                            [ class "button connect"
                            , disabled (isBlank model.editorContent)
                            , onMouseDown
                                (AppMsg.TimelineMsg
                                    (ConfirmPostAndConnect
                                        model.editorContent
                                        Nothing
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
                    , onMouseDown (AppMsg.TimelineMsg TimelineMsg.Post)
                    ]
                    [ text "Post"
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
                    , placeholder "Write your Coto in Markdown"
                    , defaultValue model.editorContent
                    , onFocus (AppMsg.TimelineMsg EditorFocus)
                    , onInput (AppMsg.TimelineMsg << EditorInput)
                    , on "keydown" <|
                        Decode.map
                            (AppMsg.TimelineMsg << EditorKeyDown)
                            Util.Keyboard.Event.decodeKeyboardEvent
                    , onClickWithoutPropagation NoOp
                    ]
                    []
              )
            ]
        ]


newCotoButton : Timeline -> Html AppMsg.Msg
newCotoButton timeline =
    a
        [ class "tool-button new-coto-button"
        , title "New Coto"
        , hidden (timeline.editorOpen)
        , onClick OpenNewEditorModal
        ]
        [ materialIcon "create" Nothing
        , span [ class "shortcut" ] [ text "(Press N key)" ]
        ]
