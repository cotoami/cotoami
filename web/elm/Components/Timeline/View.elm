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
import App.Types exposing (Session)
import App.Markdown exposing (markdownOptions, markdownElements)
import Components.Timeline.Model exposing (Coto, Model)
import Components.Timeline.Messages exposing (..)


view : Model -> Maybe Session -> Maybe Int -> Html Msg
view model session activeCotoId =
    div [ id "timeline-column", class (timelineClass model) ]
        [ timelineDiv model session activeCotoId
        , div [ id "new-coto" ]
            [ div [ class "toolbar", hidden (not model.editingNewCoto) ]
                [ (case session of
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


timelineDiv : Model -> Maybe Session -> Maybe Int  -> Html Msg
timelineDiv model session activeCotoId =
    Html.Keyed.node
        "div"
        [ id "timeline" ]
        (List.map 
            (\coto -> 
                ( getKey coto
                , div
                    [ classList 
                        [ ( "coto", True )
                        , ( "active", isActive coto activeCotoId )
                        , ( "posting", (isJust session) && (isNothing coto.id) )
                        , ( "being-hidden", coto.beingDeleted )
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
                                , onOpenCotoClick (CotoOpen coto)
                                ] 
                                [ i [ class "material-icons" ] [ text "open_in_new" ] ]
                      )
                    , markdown coto.content 
                    ]
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
        

isActive : Coto -> Maybe Int -> Bool
isActive coto activeCotoId =
    case coto.id of
        Nothing -> False
        Just cotoId -> (Maybe.withDefault -1 activeCotoId) == cotoId
    
        
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
  

onOpenCotoClick : msg -> Attribute msg
onOpenCotoClick message =
    let
        defaultOptions = Html.Events.defaultOptions
    in
        onWithOptions 
            "click"
            { defaultOptions | stopPropagation = True }
            (Decode.succeed message)
  
  
