module App.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on, onClick, keyCode, onFocus, onBlur, onInput, onMouseDown, onCheck)
import Json.Decode as Decode
import Markdown
import Exts.Maybe exposing (isJust)
import Utils exposing (isBlank, validateEmail)
import App.Model exposing (..)
import App.Messages exposing (..)
import Components.AppHeader
import Components.SigninModal

view : Model -> Html Msg
view model =
    div [ id "app" ]
        [ Components.AppHeader.view model
        , div [ id "app-body", class "container" ]
            [ div [ id "timeline-column", class (timelineClass model) ]
                [ div [ id "timeline" ]
                    (List.map (\coto -> div [ class "coto" ] [ markdown coto.content ]) (List.reverse model.cotos))
                , div [ id "new-coto" ]
                    [ div [ class "toolbar", hidden (not model.editingNewCoto) ]
                        [ (case model.session of
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
                            [ button [ class "button-primary", disabled (isBlank model.newCoto), onMouseDown Post ]
                                [ text "Post"
                                , span [ class "shortcut-help" ] [ text "(Ctrl + Enter)" ]
                                ]
                            ]
                        ]
                    , textarea
                        [ class "coto"
                        , placeholder "Write your idea in Markdown"
                        , value model.newCoto
                        , onFocus EditorFocus
                        , onBlur EditorBlur
                        , onInput EditorInput
                        , onKeyDown EditorKeyDown
                        ]
                        []
                    ]
                ]
            ]
        , Html.map SigninModalMsg 
            (Components.SigninModal.view 
                model.signinModal
                ((isJust model.session) || (List.isEmpty model.cotos))
            )
        ]


markdown : String -> Html msg
markdown content =
    let
        defaultOptions = Markdown.defaultOptions
    in
        Markdown.toHtmlWith 
            { defaultOptions 
            | githubFlavored = Just { tables = True, breaks = True }
            , sanitize = True
            , smartypants = True
            } 
            [ class "content" ] 
            content


timelineClass : Model -> String
timelineClass model =
    if model.editingNewCoto then
        "editing"
    else
        ""


onKeyDown : (Int -> msg) -> Attribute msg
onKeyDown tagger =
    on "keydown" (Decode.map tagger keyCode)
