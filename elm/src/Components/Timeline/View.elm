module Components.Timeline.View exposing (..)

import Html exposing (..)
import Html.Keyed
import Html.Attributes exposing (..)
import Html.Events
import Html.Events exposing (..)
import Html.Lazy exposing (lazy2)
import Json.Decode as Decode
import Markdown.Block as Block exposing (Block(..))
import Markdown.Inline as Inline exposing (Inline(..))
import Exts.Maybe exposing (isJust, isNothing)
import Utils exposing (isBlank, onClickWithoutPropagation)
import App.Types exposing (Cotonoma, CotoSelection, Context)
import App.Types.Session exposing (Session)
import App.Graph exposing (Graph, member)
import App.Markdown
import Components.Timeline.Model exposing (Post, Model, toCoto)
import Components.Timeline.Messages exposing (..)
import Components.Coto


view : Context -> Graph -> Model -> Html Msg
view context graph model =
    div [ id "input-and-timeline", class (timelineClass model) ]
        [ timelineDiv context graph model
        , lazy2 newPostEditor context model
        ]


newPostEditor : Context -> Model -> Html Msg
newPostEditor context model =
    div [ id "new-coto" ]
        [ div [ class "toolbar", hidden (not model.editingNew) ]
            [ (case context.session of
                  Nothing ->
                      span [ class "user anonymous" ]
                          [ i [ class "material-icons" ] [ text "perm_identity" ]
                          , text "Anonymous"
                          ]
                  Just session ->
                      span [ class "user session" ]
                          [ img [ class "avatar", src session.avatarUrl ] []
                          , span [ class "name" ] [ text session.displayName ]
                          ]
              )
            , div [ class "tool-buttons" ]
                [ button
                    [ class "button-primary"
                    , disabled (isBlank model.newContent)
                    , onMouseDown Components.Timeline.Messages.Post
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


timelineDiv : Context -> Graph -> Model -> Html Msg
timelineDiv context graph model =
    Html.Keyed.node
        "div"
        [ id "timeline", classList [ ( "loading", model.loading ) ] ]
        (List.map
            (\post ->
                ( getKey post
                , postDiv context graph post
                )
            )
            (List.reverse model.posts)
        )


getKey : Post -> String
getKey post =
    case post.cotoId of
        Just cotoId -> toString cotoId
        Nothing ->
            case post.postId of
                Just postId -> toString postId
                Nothing -> ""


postDiv : Context -> Graph -> Post -> Html Msg
postDiv context graph post =
    div
        (classList
            [ ( "coto", True )
            , ( "selectable", True )
            , ( "focus", post.cotoId == context.focus )
            , ( "selected", isActive context.selection post )
            , ( "posting", (isJust context.session) && (isNothing post.cotoId) )
            , ( "being-hidden", post.beingDeleted )
            ] ::
                (case post.cotoId of
                    Nothing -> []
                    Just cotoId ->
                        [ onClick (PostClick cotoId)
                        , onMouseEnter (PostMouseEnter cotoId)
                        , onMouseLeave (PostMouseLeave cotoId)
                        ]
                )
        )
        [ div
            [ class "coto-inner" ]
            [ headerDiv context.cotonoma graph post
            , authorDiv context.session post
            , bodyDiv context graph post
            , Components.Coto.openTraversalButtonDiv OpenTraversal post.cotoId graph
            ]
        ]


isActive : CotoSelection -> Post -> Bool
isActive selection post =
    case post.cotoId of
        Nothing -> False
        Just cotoId -> List.member cotoId selection


headerDiv : Maybe Cotonoma -> Graph -> Post -> Html Msg
headerDiv maybeCotonoma graph post =
    case toCoto post of
        Nothing ->
            div [ class "coto-header" ] []
        Just coto ->
            Components.Coto.headerDiv CotonomaClick maybeCotonoma graph coto


authorDiv : Maybe Session -> Post -> Html Msg
authorDiv maybeSession post =
    case maybeSession of
        Nothing -> span [] []
        Just session ->
            case post.amishi of
                Nothing -> span [] []
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
    Components.Coto.bodyDiv
        context
        graph
        { openCoto = Just (OpenPost post)
        , selectCoto = Just SelectCoto
        , openTraversal = Just OpenTraversal
        , cotonomaClick = CotonomaClick
        , deleteConnection = Nothing
        , markdown = markdown
        }
        { cotoId = post.cotoId
        , content = post.content
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


customHtmlInline : Inline i -> Html Msg
customHtmlInline inline =
    case inline of
        Image source maybeTitle inlines ->
            img [ src source
                , title (Maybe.withDefault "" maybeTitle)
                , onLoad ImageLoaded
                ] (List.map customHtmlInline inlines)

        _ ->
            App.Markdown.customHtmlInline inline


timelineClass : Model -> String
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
