module App.Views.Post exposing (view, postDivAttrs, headerDiv, authorDiv)

import Set
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Markdown.Block as Block exposing (Block(..))
import Markdown.Inline as Inline exposing (Inline(..))
import Exts.Maybe exposing (isJust, isNothing)
import Utils.DateUtil
import Utils.HtmlUtil
import Utils.EventUtil exposing (onLoad)
import App.Types.Coto exposing (ElementId)
import App.Types.Post exposing (Post, toCoto)
import App.Types.Graph exposing (Direction(..), Graph)
import App.Submodels.Context exposing (Context)
import App.Messages exposing (..)
import App.Views.FlowMsg
import App.Markdown exposing (extractTextFromMarkdown)
import App.Views.Coto


view : Context a -> Graph -> Post -> Html Msg
view context graph post =
    let
        elementId =
            "timeline-" ++ (Maybe.withDefault "none" post.cotoId)
    in
        div
            (postDivAttrs context graph elementId post)
            [ div
                [ class "coto-inner" ]
                [ headerDiv context graph elementId post
                , post.cotoId
                    |> Maybe.map (\cotoId -> App.Views.Coto.parentsDiv graph Nothing cotoId)
                    |> Maybe.withDefault Utils.HtmlUtil.none
                , if post.isCotonoma then
                    Utils.HtmlUtil.none
                  else
                    authorDiv context post
                , App.Views.Coto.bodyDiv context elementId markdown post
                , footerDiv post
                , App.Views.Coto.subCotosButtonDiv graph Nothing post.cotoId
                , authorIcon context post
                ]
            ]


postDivAttrs : Context a -> Graph -> String -> Post -> List (Attribute Msg)
postDivAttrs context graph elementId post =
    let
        classAttr =
            App.Views.Coto.cotoClassList context
                elementId
                post.cotoId
                [ ( "posting", (isJust context.session) && (isNothing post.cotoId) )
                , ( "being-hidden", post.beingDeleted )
                , ( "by-another-amishi", not (isAuthor context post) )
                , ( "in-pinned-graph"
                  , post.cotoId
                        |> Maybe.map (\cotoId -> Set.member cotoId graph.reachableCotoIds)
                        |> Maybe.withDefault False
                  )
                ]

        eventAttrs =
            post.cotoId
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
    (Maybe.map2
        (\session author -> author.id == session.id)
        context.session
        post.amishi
    )
        |> Maybe.withDefault False


headerDiv : Context a -> Graph -> ElementId -> Post -> Html Msg
headerDiv context graph elementId post =
    toCoto post
        |> Maybe.map (App.Views.Coto.headerDiv context graph Nothing elementId)
        |> Maybe.withDefault (div [ class "coto-header" ] [])


authorDiv : Context a -> Post -> Html Msg
authorDiv context post =
    (Maybe.map2
        (\session author ->
            if author.id /= session.id then
                div [ class "amishi author" ]
                    [ img [ class "avatar", src author.avatarUrl ] []
                    , span [ class "name" ] [ text author.displayName ]
                    ]
            else
                Utils.HtmlUtil.none
        )
        context.session
        post.amishi
    )
        |> Maybe.withDefault Utils.HtmlUtil.none


authorIcon : Context a -> Post -> Html Msg
authorIcon context post =
    (Maybe.map2
        (\session author ->
            if author.id /= session.id then
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
    )
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
