module Components.SigninModal exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput, onCheck)
import Http
import Json.Decode as Decode
import Util.StringUtil exposing (validateEmail)
import Util.Modal as Modal
import App.Messages exposing (Msg(..))
import App.Types.SigninModal exposing (..)



update : Msg -> SigninModal -> ( SigninModal, Cmd Msg )
update msg model =
    case msg of
        SigninClose ->
            ( model, Cmd.none )

        SigninEmailInput content ->
            ( { model | email = content }, Cmd.none )

        SigninSaveAnonymousCotosCheck checked ->
            ( { model | saveAnonymousCotos = checked }, Cmd.none )

        SigninRequestClick ->
            { model | requestProcessing = True }
                ! [ requestSignin model.email model.saveAnonymousCotos ]

        SigninRequestDone (Ok message) ->
            ( { model | email = "", requestProcessing = False, requestDone = True }, Cmd.none )

        SigninRequestDone (Err _) ->
            ( { model | requestProcessing = False }, Cmd.none )

        _ ->
            ( model, Cmd.none )


requestSignin : String -> Bool -> Cmd Msg
requestSignin email saveAnonymous =
    let
        url =
            "/api/signin/request/"
                ++ email
                ++ (if saveAnonymous then
                        "/yes"
                    else
                        "/no"
                   )
    in
        Http.send SigninRequestDone (Http.get url Decode.string)


view : SigninModal -> Bool -> Html Msg
view model showAnonymousOption =
    signinModalConfig model showAnonymousOption
        |> Just
        |> Modal.view "signin-modal"


signinModalConfig : SigninModal -> Bool -> Modal.Config Msg
signinModalConfig model showAnonymousOption =
    (if model.requestDone then
        { closeMessage = SigninClose
        , title = "Check your inbox!"
        , content =
            div [ id "signin-modal-content" ]
                [ p [] [ text "We just sent you an email with a link to access (or create) your Cotoami account." ] ]
        , buttons =
            [ button [ class "button", onClick SigninClose ] [ text "OK" ] ]
        }
     else
        { closeMessage = SigninClose
        , title = "Sign in/up with your email"
        , content =
            div []
                [ p [] [ text "Welcome to Cotoami!" ]
                , p [] [ text "Cotoami doesn't use passwords. Just enter your email address and we'll send you a sign-in (or sign-up) link." ]
                , Html.form [ name "signin" ]
                    [ div []
                        [ input
                            [ type_ "email"
                            , class "u-full-width"
                            , name "email"
                            , placeholder "you@example.com"
                            , value model.email
                            , onInput SigninEmailInput
                            ]
                            []
                        ]
                    , (if showAnonymousOption then
                        div [ class "save-anonymous-cotos-option" ]
                            [ label []
                                [ input [ type_ "checkbox", onCheck SigninSaveAnonymousCotosCheck ] []
                                , span [ class "label-body" ]
                                    [ text "Save the anonymous cotos (posts) into your account" ]
                                ]
                            ]
                       else
                        div [] []
                      )
                    ]
                ]
        , buttons =
            [ button
                [ class "button close", onClick SigninClose ]
                [ text "Try it out w/o signing up" ]
            , button
                [ class "button button-primary"
                , disabled (not (validateEmail model.email) || model.requestProcessing)
                , onClick SigninRequestClick
                ]
                [ if model.requestProcessing then
                    text "Sending..."
                  else
                    text "OK"
                ]
            ]
        }
    )
