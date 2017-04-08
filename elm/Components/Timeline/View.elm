module Components.Timeline.View exposing (..)

import Html exposing (..)
import Html.Keyed
import Html.Attributes exposing (..)
import Html.Events
import Html.Events exposing 
    (on, onWithOptions, onClick, onMouseDown, onFocus, onBlur, onInput, keyCode)
import Json.Decode as Decode
import Markdown
import Markdown.Config exposing (defaultElements, defaultOptions)
import Exts.Maybe exposing (isJust, isNothing)
import Utils exposing (isBlank, onClickWithoutPropagation)
import App.Types exposing (Session, Cotonoma, CotoSelection)
import App.Graph exposing (Graph, pinned)
import App.Markdown exposing (markdownOptions, markdownElements)
import Components.Timeline.Model exposing (Post, Model, isPostedInCotonoma)
import Components.Timeline.Messages exposing (..)


view : CotoSelection -> Maybe Cotonoma -> Maybe Session -> Graph -> Model -> Html Msg
view  selection maybeCotonoma maybeSession graph model =
    div [ id "input-and-timeline", class (timelineClass model) ]
        [ timelineDiv selection maybeCotonoma maybeSession graph model
        , div [ id "new-coto" ]
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
        [ div [ class "border" ] []
        , headerDiv maybeCotonoma graph post
        , authorDiv maybeSession post
        , bodyDiv post
        ]
        

isActive : CotoSelection -> Post -> Bool
isActive selection post =
    case post.cotoId of
        Nothing -> False
        Just cotoId -> List.member cotoId selection


headerDiv : Maybe Cotonoma -> Graph -> Post -> Html Msg
headerDiv maybeCotonoma graph post =
    div 
        [ class "coto-header" ]
        [ case post.postedIn of
            Nothing -> span [] []
            Just postedIn ->
                if not (isPostedInCotonoma maybeCotonoma post) then
                    a 
                        [ class "posted-in"
                        , onClickWithoutPropagation (CotonomaClick postedIn.key) 
                        ] 
                        [ text postedIn.name ]
                else
                    span [] []
        , case post.cotoId of
            Nothing ->
                span [] []
            Just cotoId -> 
                if pinned cotoId graph then
                    i [ class "pinned fa fa-thumb-tack"
                      , (attribute "aria-hidden" "true") 
                      ] []
                else
                    span [] []
        ]


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
            
    
bodyDiv : Post -> Html Msg
bodyDiv post =
    div [ class "coto-body" ]
        [ (case post.cotoId of
            Nothing -> span [] []
            Just cotoId ->
                a 
                    [ class "tool-button open-coto"
                    , title "Open coto view"
                    , onClickWithoutPropagation (PostOpen post)
                    ] 
                    [ i [ class "material-icons" ] [ text "open_in_new" ] ]
          )
        , if post.asCotonoma then
            div [ class "coto-as-cotonoma" ]
                [ a [ onClickWithoutPropagation (CotonomaClick post.cotonomaKey) ]
                    [ i [ class "material-icons" ] [ text "exit_to_app" ]
                    , span [ class "cotonoma-name" ] [ text post.content ]
                    ]
                ]
          else 
              markdown post.content 
        ]
        
        
markdown : String -> Html Msg
markdown content =
    div [ class "content" ]
        <| Markdown.customHtml 
            markdownOptions
            { markdownElements
            | image = customImageElement
            }
            content


customImageElement : Markdown.Config.Image -> Html Msg
customImageElement image =
    img
        [ src image.src
        , alt image.alt
        , title (Maybe.withDefault "" image.title)
        , onLoad ImageLoaded
        ]
        []
  

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
  
  
