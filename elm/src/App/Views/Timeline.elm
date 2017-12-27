module App.Views.Timeline exposing (..)

import Html exposing (..)
import Html.Keyed
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import List.Extra exposing (groupWhile)
import Util.StringUtil exposing (isBlank)
import Util.HtmlUtil exposing (faIcon, materialIcon)
import Util.DateUtil exposing (sameDay, formatDay)
import Util.EventUtil exposing (onKeyDown, onClickWithoutPropagation)
import App.Types.Context exposing (CotoSelection, Context)
import App.Types.Post exposing (Post, toCoto)
import App.Types.Session exposing (Session)
import App.Types.Graph exposing (Direction(..), Graph, member)
import App.Types.Timeline exposing (Timeline)
import App.Messages exposing (..)
import App.Views.Post


view : Context -> Session -> Graph -> Bool -> Timeline -> Html Msg
view context session graph ready timeline =
    div
        [ id "timeline-and-input"
        , classList
            [ ( "editing", timeline.editorOpen )
            ]
        ]
        [ if not ready then
            div [ class "loading-overlay" ] []
          else
            div [] []
        , timelineDiv context graph timeline
        , postEditor context session timeline
        ]


timelineDiv : Context -> Graph -> Timeline -> Html Msg
timelineDiv context graph model =
    div [ id "timeline", class "timeline" ]
        [ moreButton context model
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


moreButton : Context -> Timeline -> Html Msg
moreButton context timeline =
    if timeline.more then
        div [ class "more-button-div" ]
            [ if timeline.loadingMore then
                button
                    [ class "button more-button loading", disabled True ]
                    [ img [ src "/images/loading-horizontal.gif" ] [] ]
              else
                button
                    [ class "button more-button"
                    , onClick
                        (context.cotonoma
                            |> Maybe.map (\cotonoma -> LoadMorePostsInCotonoma cotonoma.key)
                            |> Maybe.withDefault LoadMorePosts
                        )
                    ]
                    [ materialIcon "arrow_drop_up" Nothing ]
            ]
    else
        div [] []


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


postEditor : Context -> Session -> Timeline -> Html Msg
postEditor context session model =
    div [ class "quick-coto-editor" ]
        [ div [ class "toolbar", hidden (not model.editorOpen) ]
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
                            , onMouseDown
                                (App.Messages.ConfirmPostAndConnect
                                    model.newContent
                                    Nothing
                                )
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
        , Html.Keyed.node
            "div"
            []
            [ ( toString model.editorCounter
              , textarea
                    [ class "coto"
                    , id "quick-coto-input"
                    , placeholder "Write your Coto in Markdown"
                    , defaultValue model.newContent
                    , onFocus EditorFocus
                    , onInput EditorInput
                    , onKeyDown EditorKeyDown
                    , onClickWithoutPropagation NoOp
                    ]
                    []
              )
            ]
        ]
