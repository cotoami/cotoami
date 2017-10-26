module App.Views.Post exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Markdown.Block as Block exposing (Block(..))
import Markdown.Inline as Inline exposing (Inline(..))
import Exts.Maybe exposing (isJust, isNothing)
import Util.DateUtil
import Util.EventUtil exposing (onLoad)
import App.Types.Coto exposing (ElementId)
import App.Types.Context exposing (Context)
import App.Types.Post exposing (Post, toCoto)
import App.Types.Session exposing (Session)
import App.Types.Graph exposing (Direction(..), Graph, member, getParents)
import App.Messages exposing (..)
import App.Markdown exposing (extractTextFromMarkdown)
import App.Views.Coto


view : Context -> Graph -> Post -> Html Msg
view context graph post =
    let
        elementId =
            "timeline-" ++ (Maybe.withDefault "none" post.cotoId)

        classAttr =
            App.Views.Coto.cotoClassList context
                elementId
                post.cotoId
                [ ( "posting", (isJust context.session) && (isNothing post.cotoId) )
                , ( "being-hidden", post.beingDeleted )
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
        div
            (classAttr :: eventAttrs)
            [ div
                [ class "coto-inner" ]
                [ headerDiv context graph post
                , parentsDiv graph post
                , if post.asCotonoma then
                    div [] []
                  else
                    authorDiv context.session post
                , bodyDiv context graph elementId post
                , footerDiv post
                , App.Views.Coto.openTraversalButtonDiv OpenTraversal post.cotoId graph
                ]
            ]


headerDiv : Context -> Graph -> Post -> Html Msg
headerDiv context graph post =
    post
        |> toCoto
        |> Maybe.map (App.Views.Coto.headerDiv CotonomaClick context graph)
        |> Maybe.withDefault (div [ class "coto-header" ] [])


parentsDiv : Graph -> Post -> Html Msg
parentsDiv graph post =
    let
        parents =
            post.cotoId
                |> Maybe.map (\cotoId -> getParents cotoId graph)
                |> Maybe.withDefault []
    in
        if List.isEmpty parents then
            div [] []
        else
            div [ class "parents" ]
                (List.map
                    (\parent ->
                        div
                            [ class "parent"
                            , onClick (OpenTraversal parent.id)
                            ]
                            [ text (App.Views.Coto.abbreviate parent) ]
                    )
                    parents
                )


authorDiv : Maybe Session -> Post -> Html Msg
authorDiv maybeSession post =
    (Maybe.map2
        (\session author ->
            if author.id == session.id then
                span [] []
            else
                div [ class "amishi author" ]
                    [ img [ class "avatar", src author.avatarUrl ] []
                    , span [ class "name" ] [ text author.displayName ]
                    ]
        )
        maybeSession
        post.amishi
    )
        |> Maybe.withDefault (span [] [])


bodyDiv : Context -> Graph -> ElementId -> Post -> Html Msg
bodyDiv context graph elementId post =
    App.Views.Coto.bodyDivWithConfig
        context
        graph
        elementId
        { openCoto = Just (OpenPost post)
        , selectCoto = Just SelectCoto
        , pinCoto = Just PinCoto
        , openTraversal = Just OpenTraversal
        , confirmConnect = Just ConfirmConnect
        , deleteConnection = Nothing
        , markdown = markdown
        }
        { cotoId = post.cotoId
        , content = post.content
        , summary = post.summary
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
                    [ text (Util.DateUtil.format "en_us" "%H:%M:%S" postedAt) ]
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
