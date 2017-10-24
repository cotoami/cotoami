module App.Views.Timeline exposing (..)

import Html exposing (..)
import Html.Keyed
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import List.Extra exposing (groupWhile)
import Exts.Maybe exposing (isJust, isNothing)
import Util.StringUtil exposing (isBlank)
import Util.HtmlUtil exposing (faIcon)
import Util.DateUtil exposing (sameDay, formatDay)
import Util.EventUtil exposing (onKeyDown)
import App.Types.Context exposing (CotoSelection, Context)
import App.Types.Post exposing (Post, toCoto)
import App.Types.Session exposing (Session)
import App.Types.Graph exposing (Direction(..), Graph, member)
import App.Types.Timeline exposing (Timeline)
import App.Messages exposing (..)
import App.Views.Post


view : Context -> Graph -> Timeline -> Html Msg
view context graph timeline =
    div [ id "input-and-timeline", class (timelineClass timeline) ]
        [ timelineDiv context graph timeline
        , homeTimelineHelp context timeline
        , context.session
            |> Maybe.map (\session -> postEditor session context timeline)
            |> Maybe.withDefault (div [] [])
        ]


homeTimelineHelp : Context -> Timeline -> Html Msg
homeTimelineHelp context timeline =
    if
        (isJust context.session)
            && (not context.cotonomaLoading)
            && (isNothing context.cotonoma)
            && (App.Types.Timeline.isEmpty timeline)
    then
        div [ class "home-timeline-help" ]
            [ p [] [ text "Welcome to Cotoami!" ]
            , p [] [ text "This is your home timeline." ]
            , p []
                [ text
                    ("Posts here are private to you as long as "
                        ++ "they are not cotonomas or connected from cotonomas."
                    )
                ]
            ]
    else
        div [] []


postEditor : Session -> Context -> Timeline -> Html Msg
postEditor session context model =
    div [ id "new-coto" ]
        [ div [ class "toolbar", hidden (not model.editingNew) ]
            [ span [ class "user session" ]
                [ img [ class "avatar", src session.avatarUrl ] []
                , span [ class "name" ] [ text session.displayName ]
                ]
            , div [ class "tool-buttons" ]
                [ if List.isEmpty context.selection then
                    span [] []
                  else
                    span [ class "connect-buttons" ]
                        [ button
                            [ class "button connect"
                            , disabled (isBlank model.newContent)
                            , onMouseDown App.Messages.ConfirmPostAndConnect
                            ]
                            [ faIcon "link" Nothing
                            , span [ class "shortcut-help" ] [ text "(Alt + Enter)" ]
                            ]
                        ]
                , button
                    [ class "button-primary post"
                    , disabled (isBlank model.newContent)
                    , onMouseDown App.Messages.Post
                    ]
                    [ text "Post"
                    , span [ class "shortcut-help" ] [ text "(Ctrl + Enter)" ]
                    ]
                ]
            ]
        , textarea
            [ class "coto"
            , placeholder "Write your idea in Markdown"
            , value model.newContent
            , onFocus EditorFocus
            , onBlur EditorBlur
            , onInput EditorInput
            , onKeyDown EditorKeyDown
            ]
            []
        ]


timelineDiv : Context -> Graph -> Timeline -> Html Msg
timelineDiv context graph model =
    model.posts
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
        |> Html.Keyed.node
            "div"
            [ id "timeline", classList [ ( "loading", model.loading ) ] ]


postsDiv : Context -> Graph -> List Post -> Html Msg
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


timelineClass : Timeline -> String
timelineClass model =
    if model.editingNew then
        "editing"
    else
        ""
