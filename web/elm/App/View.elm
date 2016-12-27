module App.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on, onClick, keyCode, onFocus, onBlur, onInput, onMouseDown, onCheck)
import Json.Decode as Decode
import Markdown
import Exts.Maybe exposing (isJust)
import Utils exposing (isBlank, validateEmail)
import Modal
import App.Model exposing (..)
import App.Messages exposing (..)

view : Model -> Html Msg
view model =
    div [ id "app" ]
        [ div [ id "app-header" ]
            [ div [ class "title" ]
                [ i [ class "material-icons" ] [ text "home" ]
                ]
            , div [ class "user" ]
                (case model.session of
                    Nothing -> 
                        [ a [ href "#", title "Sign in", onClick SigninClick ] 
                            [ i [ class "material-icons" ] [ text "perm_identity" ] ] 
                        ]
                    Just session -> 
                        [ img [ class "avatar", src session.avatarUrl ] [] ]
                )
            ]
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
        , Modal.view
            (if model.showSigninModal then
                Just (signinModalConfig model)
             else
                Nothing
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


signinModalConfig : Model -> Modal.Config Msg
signinModalConfig model =
    (if model.signinRequestDone then
        { closeMessage = SigninModalClose
        , title = "Check your inbox!"
        , content = div [ id "signin-modal-content" ]
            [ p [] [ text "We just sent you an email with a link to access (or create) your Cotoami account." ] ]
        , buttons = 
            [ button [ class "button", onClick SigninModalClose ] [ text "OK" ] ]
        }
    else
        { closeMessage = SigninModalClose
        , title = "Sign in with your email"
        , content = div [ id "signin-modal-content" ]
            [ p [] [ text "Cotoami doesn't use passwords. Just enter your email address and we'll send you a sign-in (or sign-up) link." ]
            , Html.form [ name "signin" ]
                [ div []
                    [ input 
                      [ type_ "email"
                      , class "u-full-width"
                      , name "signinEmail"
                      , placeholder "test@example.com"
                      , value model.signinEmail
                      , onInput SigninEmailInput
                      ] 
                      [] 
                    ]
                , (if (isJust model.session) || List.isEmpty(model.cotos) then
                    div [] []
                  else
                    div []
                        [ label [] 
                            [ input [ type_ "checkbox", onCheck SigninWithAnonymousCotosCheck ] []
                            , span [ class "label-body" ] 
                                [ text "Save the anonymous cotos (posts) into your account" ]
                            ]
                        ]
                  )
                ]
            ]
        , buttons = 
            [ button [ class "button", onClick SigninModalClose ] [ text "Cancel" ]
            , button 
                [ class "button button-primary"
                , disabled (not (validateEmail model.signinEmail) || model.signinRequestProcessing)
                , onClick SigninRequestClick 
                ] 
                [ if model.signinRequestProcessing then text "Sending..." else text "OK" ]
            ]
        }
    )
