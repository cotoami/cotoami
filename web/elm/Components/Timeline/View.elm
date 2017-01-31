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
import Utils exposing (isBlank)
import App.Types exposing (Session, Cotonoma)
import App.Markdown exposing (markdownOptions, markdownElements)
import Components.Timeline.Model exposing (Coto, Model)
import Components.Timeline.Messages exposing (..)


view : Model -> Maybe Session -> Maybe Cotonoma -> Maybe Int -> Html Msg
view model maybeSession maybeCotonoma activeCotoId =
    div [ id "timeline-column", class (timelineClass model) ]
        [ timelineDiv model maybeSession maybeCotonoma activeCotoId
        , div [ id "new-coto" ]
            [ div [ class "toolbar", hidden (not model.editingNewCoto) ]
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
                        , disabled (isBlank model.newCotoContent)
                        , onMouseDown Post 
                        ]
                        [ text "Post"
                        , span [ class "shortcut-help" ] [ text "(Ctrl + Enter)" ]
                        ]
                    ]
                ]
            , textarea
                [ class "coto"
                , placeholder "Write your idea in Markdown"
                , value model.newCotoContent
                , onFocus EditorFocus
                , onBlur EditorBlur
                , onInput EditorInput
                , onKeyDown EditorKeyDown
                ]
                []
            ]
        ]


timelineDiv : Model -> Maybe Session -> Maybe Cotonoma -> Maybe Int -> Html Msg
timelineDiv model maybeSession maybeCotonoma activeCotoId =
    Html.Keyed.node
        "div"
        [ id "timeline" ]
        (List.map 
            (\coto -> 
                ( getKey coto
                , cotoDiv maybeSession maybeCotonoma activeCotoId coto
                )
            ) 
            (List.reverse model.cotos)
        )


getKey : Coto -> String
getKey coto =
    case coto.id of
        Just cotoId -> toString cotoId
        Nothing -> 
            case coto.postId of
                Just postId -> toString postId
                Nothing -> ""
    
    
cotoDiv : Maybe Session -> Maybe Cotonoma -> Maybe Int -> Coto -> Html Msg
cotoDiv maybeSession maybeCotonoma activeCotoId coto =
    let
        postedInAnother = not (isCotoFrom maybeCotonoma coto)
    in
        div
            [ classList 
                [ ( "coto", True )
                , ( "active", isActive coto activeCotoId )
                , ( "posting", (isJust maybeSession) && (isNothing coto.id) )
                , ( "being-hidden", coto.beingDeleted )
                , ( "posted-in-another-cotonoma", postedInAnother )
                ]
            , (case coto.id of
                Nothing -> onClick NoOp
                Just cotoId -> onClick (CotoClick cotoId)
              )
            ] 
            [ div [ class "border" ] []
            ,  (case coto.id of
                Nothing -> span [] []
                Just cotoId ->
                    a 
                        [ class "open-coto"
                        , title "Open coto view"
                        , onClickWithoutPropagation (CotoOpen coto)
                        ] 
                        [ i [ class "material-icons" ] [ text "open_in_new" ] ]
              )
            , (case coto.postedIn of
                Nothing -> span [] []
                Just postedIn ->
                    if postedInAnother then
                        a 
                            [ class "posted-in"
                            , onClickWithoutPropagation (CotonomaClick postedIn.key) 
                            ] 
                            [ text postedIn.name ]
                    else
                        span [] []
              )
            , cotoContent coto
            ]
        

isCotoFrom : Maybe Cotonoma -> Coto -> Bool
isCotoFrom maybeCotonoma coto =
    case maybeCotonoma of
        Nothing -> isNothing coto.postedIn
        Just cotonoma -> 
            case coto.postedIn of
                Nothing -> False
                Just postedIn -> postedIn.id == cotonoma.id


isActive : Coto -> Maybe Int -> Bool
isActive coto activeCotoId =
    case coto.id of
        Nothing -> False
        Just cotoId -> (Maybe.withDefault -1 activeCotoId) == cotoId
    
    
cotoContent : Coto -> Html Msg
cotoContent coto =
    if coto.asCotonoma then
        div [ class "coto-as-cotonoma" ]
            [ a [ onClickWithoutPropagation (CotonomaClick coto.cotonomaKey) ]
                [ i [ class "material-icons" ] [ text "exit_to_app" ]
                , span [ class "cotonoma-name" ] [ text coto.content ]
                ]
            ]
    else 
        markdown coto.content 
        
        
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
    if model.editingNewCoto then
        "editing"
    else
        ""


onKeyDown : (Int -> msg) -> Attribute msg
onKeyDown tagger =
    on "keydown" (Decode.map tagger keyCode)


onLoad : msg -> Attribute msg
onLoad message =
    on "load" (Decode.succeed message)
  

onClickWithoutPropagation : msg -> Attribute msg
onClickWithoutPropagation message =
    let
        defaultOptions = Html.Events.defaultOptions
    in
        onWithOptions 
            "click"
            { defaultOptions | stopPropagation = True }
            (Decode.succeed message)
  
  
