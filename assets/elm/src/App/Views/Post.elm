module App.Views.Post exposing (authorDiv, headerDiv, postDivAttrs, view)

import App.Markdown exposing (extractTextFromMarkdown)
import App.Messages exposing (..)
import App.Submodels.Context exposing (Context)
import App.Types.Amishi exposing (Amishi)
import App.Types.Coto exposing (ElementId)
import App.Types.Graph
import App.Types.Post exposing (Post, toCoto)
import App.Views.Coto
import App.Views.FlowMsg
import Exts.Maybe exposing (isJust, isNothing)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Markdown.Block as Block exposing (Block(..))
import Markdown.Inline as Inline exposing (Inline(..))
import Utils.DateUtil
import Utils.EventUtil exposing (onLoad)
import Utils.HtmlUtil exposing (materialIcon)


view : Context a -> Post -> Html Msg
view context post =
    let
        elementId =
            "timeline-" ++ Maybe.withDefault "none" post.cotoId

        originalCoto =
            App.Types.Post.toCoto post

        originalCotoId =
            Maybe.map .id originalCoto
    in
    div
        (postDivAttrs context elementId post)
        [ div
            [ class "coto-inner" ]
            [ repostHeaderDiv context post
            , headerDiv context elementId post
            , originalCotoId
                |> Maybe.map (App.Views.Coto.parentsDiv context.graph Nothing)
                |> Maybe.withDefault Utils.HtmlUtil.none
            , originalCoto
                |> Maybe.map
                    (\coto ->
                        coto.asCotonoma
                            |> Maybe.map (\_ -> Utils.HtmlUtil.none)
                            |> Maybe.withDefault (authorDiv context coto.amishi)
                    )
                |> Maybe.withDefault Utils.HtmlUtil.none
            , post.repost
                |> Maybe.map (App.Views.Coto.bodyDiv context Nothing elementId markdown)
                |> Maybe.withDefault (App.Views.Coto.bodyDiv context Nothing elementId markdown post)
            , footerDiv post
            , originalCotoId
                |> Maybe.map (App.Views.Coto.openTraversalButtonDiv context.graph post.isCotonoma)
                |> Maybe.withDefault Utils.HtmlUtil.none
            , authorIcon context post
            ]
        ]


postDivAttrs : Context context -> String -> Post -> List (Attribute Msg)
postDivAttrs context elementId post =
    let
        originalCotoId =
            App.Types.Post.toCoto post |> Maybe.map .id

        classAttr =
            App.Views.Coto.cotoClassList context
                elementId
                originalCotoId
                [ ( "posting", isJust context.session && isNothing post.cotoId )
                , ( "being-hidden", post.beingDeleted )
                , ( "by-another-amishi", not (isAuthor context post) )
                , ( "in-pinned-graph"
                  , originalCotoId
                        |> Maybe.map
                            (\cotoId ->
                                App.Types.Graph.reachableFromPins cotoId context.graph
                            )
                        |> Maybe.withDefault False
                  )
                ]

        eventAttrs =
            originalCotoId
                |> Maybe.map
                    (\cotoId ->
                        [ onClick (CotoClick elementId cotoId)
                        , onMouseEnter (CotoMouseEnter elementId cotoId)
                        , onMouseLeave (CotoMouseLeave elementId cotoId)
                        ]
                    )
                |> Maybe.withDefault []
    in
    classAttr :: eventAttrs


isAuthor : Context a -> Post -> Bool
isAuthor context post =
    Maybe.map2
        (\session author -> author.id == session.amishi.id)
        context.session
        post.amishi
        |> Maybe.withDefault False


repostHeaderDiv : Context context -> Post -> Html Msg
repostHeaderDiv context post =
    post.repost
        |> Maybe.map
            (\repost ->
                div [ class "repost-header" ]
                    [ div [ class "repost-icon" ] [ materialIcon "repeat" Nothing ]
                    , if isAuthor context post then
                        Utils.HtmlUtil.none

                      else
                        authorDiv context post.amishi
                    ]
            )
        |> Maybe.withDefault Utils.HtmlUtil.none


headerDiv : Context a -> ElementId -> Post -> Html Msg
headerDiv context elementId post =
    toCoto post
        |> Maybe.map (App.Views.Coto.headerDiv context Nothing elementId)
        |> Maybe.withDefault (div [ class "coto-header" ] [])


authorDiv : Context context -> Maybe Amishi -> Html Msg
authorDiv context maybeAmishi =
    Maybe.map2
        (\session author ->
            if author.id /= session.amishi.id then
                div [ class "amishi author" ]
                    [ img [ class "avatar", src author.avatarUrl ] []
                    , span [ class "name" ] [ text author.displayName ]
                    ]

            else
                Utils.HtmlUtil.none
        )
        context.session
        maybeAmishi
        |> Maybe.withDefault Utils.HtmlUtil.none


authorIcon : Context a -> Post -> Html Msg
authorIcon context post =
    Maybe.map2
        (\session author ->
            if author.id /= session.amishi.id then
                img
                    [ class "author-icon-in-tile"
                    , src author.avatarUrl
                    , title author.displayName
                    ]
                    []

            else
                Utils.HtmlUtil.none
        )
        context.session
        post.amishi
        |> Maybe.withDefault Utils.HtmlUtil.none


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
        [ post.postedAt
            |> Maybe.map
                (\postedAt ->
                    span [ class "posted-at" ]
                        [ text (Utils.DateUtil.format "en_us" "%H:%M:%S" postedAt) ]
                )
            |> Maybe.withDefault Utils.HtmlUtil.none
        ]


customHtmlInline : Inline i -> Html Msg
customHtmlInline inline =
    case inline of
        Image source maybeTitle inlines ->
            img
                [ src source
                , title (Maybe.withDefault "" maybeTitle)
                , onLoad (FlowMsg App.Views.FlowMsg.ImageLoaded)
                ]
                (List.map customHtmlInline inlines)

        _ ->
            App.Markdown.customHtmlInline inline
