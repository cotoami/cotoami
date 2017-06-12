module Components.Timeline.View exposing (..)

import Html exposing (..)
import Html.Keyed
import Html.Attributes exposing (..)
import Html.Events
import Html.Events exposing 
    (on, onWithOptions, onClick, onMouseDown, onFocus, onBlur, onInput, keyCode)
import Html.Lazy exposing (lazy3)
import Json.Decode as Decode
import Markdown.Block as Block exposing (Block(..))
import Markdown.Inline as Inline exposing (Inline(..))
import Exts.Maybe exposing (isJust, isNothing)
import Utils exposing (isBlank, onClickWithoutPropagation)
import App.Types exposing (Session, Cotonoma, CotoSelection)
import App.Graph exposing (Graph, member)
import App.Markdown
import Components.Timeline.Model exposing (Post, Model, toCoto)
import Components.Timeline.Messages exposing (..)
import Components.Coto


view : CotoSelection -> Maybe Cotonoma -> Maybe Session -> Graph -> Model -> Html Msg
view  selection maybeCotonoma maybeSession graph model =
    div [ id "input-and-timeline", class (timelineClass model) ]
        [ timelineDiv selection maybeCotonoma maybeSession graph model
        , lazy3 newPostEditor maybeCotonoma maybeSession model
        ]


newPostEditor : Maybe Cotonoma ->  Maybe Session -> Model -> Html Msg
newPostEditor maybeCotonoma maybeSession model =
    div [ id "new-coto" ]
        [ div [ class "toolbar", hidden (not model.editingNew) ]
            [ (case maybeSession of
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
  

timelineDiv : CotoSelection -> Maybe Cotonoma -> Maybe Session -> Graph -> Model -> Html Msg
timelineDiv selection maybeCotonoma maybeSession graph model =
    Html.Keyed.node
        "div"
        [ id "timeline", classList [ ( "loading", model.loading ) ] ]
        (List.map 
            (\post -> 
                ( getKey post
                , postDiv selection maybeCotonoma maybeSession graph post
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
    
    
postDiv : CotoSelection -> Maybe Cotonoma -> Maybe Session -> Graph -> Post -> Html Msg
postDiv selection maybeCotonoma maybeSession graph post =
    div
        [ classList 
            [ ( "coto", True )
            , ( "selectable", True )
            , ( "active", isActive selection post )
            , ( "posting", (isJust maybeSession) && (isNothing post.cotoId) )
            , ( "being-hidden", post.beingDeleted )
            ]
        , (case post.cotoId of
            Nothing -> onClick NoOp
            Just cotoId -> onClick (PostClick cotoId)
          )
        ] 
        [ div 
            [ class "coto-inner" ]
            [ headerDiv maybeCotonoma graph post
            , authorDiv maybeSession post
            , bodyDiv graph post
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
            
    
bodyDiv : Graph -> Post -> Html Msg
bodyDiv graph post =
    div [ class "coto-body" ]
        [ (case post.cotoId of
            Nothing -> span [] []
            Just cotoId ->
                span [ class "coto-tools" ]
                     [ if App.Graph.member cotoId graph then
                        a [ class "tool-button traverse-coto"
                            , title "Open coto traversal"
                            , onClickWithoutPropagation (OpenTraversal cotoId)
                            ] 
                            [ i [ class "material-icons" ] [ text "open_in_new" ] ]
                       else
                         span [] []
                     , a [ class "tool-button open-coto"
                         , title "Open coto view"
                         , onClickWithoutPropagation (PostOpen post)
                         ] 
                         [ i [ class "material-icons" ] [ text "settings" ] ]
                     ]
          )
        , if post.asCotonoma then
            div [ class "coto-as-cotonoma" ]
                [ a [ href ("/cotonomas/" ++ post.cotonomaKey)
                    , onClickWithoutPropagation (CotonomaClick post.cotonomaKey)
                    ]
                    [ i [ class "material-icons" ] [ text "exit_to_app" ]
                    , span [ class "cotonoma-name" ] [ text post.content ]
                    ]
                ]
          else 
              markdown post.content 
        ]
        
        
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
  
  
