module App.Views.Timeline exposing (..)

import Html exposing (..)
import Html.Keyed
import Html.Attributes exposing (..)
import Html.Events
import Html.Events exposing (..)
import Json.Decode as Decode
import Markdown.Block as Block exposing (Block(..))
import Markdown.Inline as Inline exposing (Inline(..))
import Exts.Maybe exposing (isJust, isNothing)
import List.Extra exposing (groupWhile)
import Util.StringUtil exposing (isBlank)
import Util.HtmlUtil exposing (faIcon)
import Util.DateUtil exposing (sameDay)
import App.Types.Context exposing (CotoSelection, Context)
import App.Types.Coto exposing (Cotonoma)
import App.Types.Post exposing (Post, toCoto)
import App.Types.Session exposing (Session)
import App.Types.Graph exposing (Direction(..), Graph, member)
import App.Types.Timeline exposing (Timeline)
import App.Messages exposing (..)
import App.Markdown
import App.Views.Coto


view : Context -> Graph -> Timeline -> Html Msg
view context graph model =
    div [ id "input-and-timeline", class (timelineClass model) ]
        [ timelineDiv context graph model
        , case context.session of
            Nothing ->
                div [] []

            Just session ->
                postEditor session context model
        ]


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
        |> groupWhile (\p1 p2 -> sameDay p1.postedAt p2.postedAt )
        |> List.map
            (\postsOnDay ->
                let
                    postDateString =
                        List.head postsOnDay
                            |> Maybe.andThen (\post -> post.postedAt)
                            |> Maybe.map (Util.DateUtil.format "%Y - %m - %d")
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
                , postDiv context graph post
                )
            )
            posts
        )


getKey : Post -> String
getKey post =
    case post.cotoId of
        Just cotoId ->
            toString cotoId

        Nothing ->
            case post.postId of
                Just postId ->
                    toString postId

                Nothing ->
                    ""


postDiv : Context -> Graph -> Post -> Html Msg
postDiv context graph post =
    let
        elementId =
            "timeline-" ++ (Maybe.withDefault "none" post.cotoId)
    in
        div
            (App.Views.Coto.cotoClassList context
                elementId
                post.cotoId
                [ ( "posting", (isJust context.session) && (isNothing post.cotoId) )
                , ( "being-hidden", post.beingDeleted )
                ]
                :: (case post.cotoId of
                        Nothing ->
                            []

                        Just cotoId ->
                            [ onClick (CotoClick elementId cotoId)
                            , onMouseEnter (CotoMouseEnter elementId cotoId)
                            , onMouseLeave (CotoMouseLeave elementId cotoId)
                            ]
                   )
            )
            [ div
                [ class "coto-inner" ]
                [ headerDiv context.cotonoma graph post
                , if post.asCotonoma then
                    div [] []
                  else
                    authorDiv context.session post
                , bodyDiv context graph post
                , footerDiv post
                , App.Views.Coto.openTraversalButtonDiv OpenTraversal post.cotoId graph
                ]
            ]


headerDiv : Maybe Cotonoma -> Graph -> Post -> Html Msg
headerDiv maybeCotonoma graph post =
    case toCoto post of
        Nothing ->
            div [ class "coto-header" ] []

        Just coto ->
            App.Views.Coto.headerDiv CotonomaClick maybeCotonoma graph coto


authorDiv : Maybe Session -> Post -> Html Msg
authorDiv maybeSession post =
    case maybeSession of
        Nothing ->
            span [] []

        Just session ->
            case post.amishi of
                Nothing ->
                    span [] []

                Just author ->
                    if author.id == session.id then
                        span [] []
                    else
                        div [ class "amishi author" ]
                            [ img [ class "avatar", src author.avatarUrl ] []
                            , span [ class "name" ] [ text author.displayName ]
                            ]


bodyDiv : Context -> Graph -> Post -> Html Msg
bodyDiv context graph post =
    App.Views.Coto.bodyDivWithConfig
        context
        graph
        { openCoto = Just (OpenPost post)
        , selectCoto = Just SelectCoto
        , pinCoto = Just PinCoto
        , openTraversal = Just OpenTraversal
        , cotonomaClick = CotonomaClick
        , confirmConnect = Just ConfirmConnect
        , deleteConnection = Nothing
        , markdown = markdown
        }
        { cotoId = post.cotoId
        , content = post.content
        , amishi = post.amishi
        , asCotonoma = post.asCotonoma
        , cotonomaKey = post.cotonomaKey
        }


markdown : String -> Html Msg
markdown markdownText =
    markdownText
        |> Block.parse (Just App.Markdown.markdownOptions)
        |> List.map (App.Markdown.customHtmlBlock customHtmlInline)
        |> List.concat
        |> div [ class "content" ]


footerDiv : Post -> Html Msg
footerDiv post =
    div
        [ class "post-footer" ]
        [ case post.postedAt of
            Nothing ->
                span [] []

            Just postedAt ->
                span
                    [ class "posted-at" ]
                    [ text (Util.DateUtil.format "%H:%M:%S" postedAt) ]
        ]


customHtmlInline : Inline i -> Html Msg
customHtmlInline inline =
    case inline of
        Image source maybeTitle inlines ->
            img
                [ src source
                , title (Maybe.withDefault "" maybeTitle)
                , onLoad ImageLoaded
                ]
                (List.map customHtmlInline inlines)

        _ ->
            App.Markdown.customHtmlInline inline


timelineClass : Timeline -> String
timelineClass model =
    if model.editingNew then
        "editing"
    else
        ""


onKeyDown : (Int -> msg) -> Attribute msg
onKeyDown tagger =
    on "keydown" (Decode.map tagger keyCode)


onLoad : msg -> Attribute msg
onLoad message =
    on "load" (Decode.succeed message)
