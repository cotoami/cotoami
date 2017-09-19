module App.Modals.SigninModal exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput, onCheck)
import Http
import Json.Decode as Decode
import Util.StringUtil exposing (validateEmail)
import Util.Modal as Modal
import App.Messages as AppMsg exposing (Msg(CloseModal))
import App.Modals.SigninModalMsg as SigninModalMsg exposing (Msg(..))


type alias Model =
    { email : String
    , saveAnonymousCotos : Bool
    , requestProcessing : Bool
    , requestDone : Bool
    }


defaultModel : Model
defaultModel =
    { email = ""
    , saveAnonymousCotos = False
    , requestProcessing = False
    , requestDone = False
    }


update : SigninModalMsg.Msg -> Model -> ( Model, Cmd SigninModalMsg.Msg )
update msg model =
    case msg of
        EmailInput content ->
            ( { model | email = content }, Cmd.none )

        SaveAnonymousCotosCheck checked ->
            ( { model | saveAnonymousCotos = checked }, Cmd.none )

        RequestClick ->
            { model | requestProcessing = True }
                ! [ requestSignin model.email model.saveAnonymousCotos ]

        RequestDone (Ok message) ->
            ( { model | email = "", requestProcessing = False, requestDone = True }, Cmd.none )

        RequestDone (Err _) ->
            ( { model | requestProcessing = False }, Cmd.none )


requestSignin : String -> Bool -> Cmd SigninModalMsg.Msg
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
        Http.send RequestDone (Http.get url Decode.string)


view : Model -> Bool -> Html AppMsg.Msg
view model showAnonymousOption =
    signinModalConfig model showAnonymousOption
        |> Just
        |> Modal.view "signin-modal"


signinModalConfig : Model -> Bool -> Modal.Config AppMsg.Msg
signinModalConfig model showAnonymousOption =
    (if model.requestDone then
        { closeMessage = CloseModal
        , title = "Check your inbox!"
        , content =
            div [ id "signin-modal-content" ]
                [ p [] [ text "We just sent you an email with a link to access (or create) your Cotoami account." ] ]
        , buttons =
            [ button [ class "button", onClick CloseModal ] [ text "OK" ] ]
        }
     else
        { closeMessage = CloseModal
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
                            , onInput (AppMsg.SigninModalMsg << EmailInput)
                            ]
                            []
                        ]
                    , (if showAnonymousOption then
                        div [ class "save-anonymous-cotos-option" ]
                            [ label []
                                [ input
                                    [ type_ "checkbox"
                                    , onCheck (AppMsg.SigninModalMsg << SaveAnonymousCotosCheck)
                                    ]
                                    []
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
                [ class "button close", onClick CloseModal ]
                [ text "Try it out w/o signing up" ]
            , button
                [ class "button button-primary"
                , disabled (not (validateEmail model.email) || model.requestProcessing)
                , onClick (AppMsg.SigninModalMsg RequestClick)
                ]
                [ if model.requestProcessing then
                    text "Sending..."
                  else
                    text "OK"
                ]
            ]
        }
    )
