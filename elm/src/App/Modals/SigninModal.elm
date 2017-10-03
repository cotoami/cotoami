module App.Modals.SigninModal exposing (Model, defaultModel, update, view)

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
    { signupEnabled : Bool
    , email : String
    , requestProcessing : Bool
    , requestDone : Bool
    }


defaultModel : Model
defaultModel =
    { signupEnabled = False
    , email = ""
    , requestProcessing = False
    , requestDone = False
    }


update : SigninModalMsg.Msg -> Model -> ( Model, Cmd SigninModalMsg.Msg )
update msg model =
    case msg of
        EmailInput content ->
            ( { model | email = content }, Cmd.none )

        RequestClick ->
            { model | requestProcessing = True }
                ! [ requestSignin model.email ]

        RequestDone (Ok message) ->
            ( { model | email = "", requestProcessing = False, requestDone = True }, Cmd.none )

        RequestDone (Err _) ->
            ( { model | requestProcessing = False }, Cmd.none )


requestSignin : String -> Cmd SigninModalMsg.Msg
requestSignin email =
    let
        url =
            "/api/public/signin/request/" ++ email
    in
        Http.send RequestDone (Http.get url Decode.string)


view : Model -> Html AppMsg.Msg
view model =
    signinModalConfig model
        |> Just
        |> Modal.view "signin-modal"


signinModalConfig : Model -> Modal.Config AppMsg.Msg
signinModalConfig model =
    (if model.requestDone then
        { closeMessage = CloseModal
        , title = "Check your inbox!"
        , content =
            div [ id "signin-modal-content" ]
                [ p [] [ text "We just sent you an email with a link to access (or create) your Cotoami account." ] ]
        , buttons =
            [ button [ class "button", onClick CloseModal ] [ text "OK" ] ]
        }
     else if model.signupEnabled then
        modalConfigWithSignupEnabled model
     else
        modalConfigOnlyForSignin model
    )


modalConfigWithSignupEnabled : Model -> Modal.Config AppMsg.Msg
modalConfigWithSignupEnabled model =
    { closeMessage = CloseModal
    , title = "Sign in/up with your email"
    , content =
        div []
            [ p [] [ text "Welcome to Cotoami!" ]
            , p [] [ text "Cotoami doesn't use passwords. Just enter your email address and we'll send you a sign-in (or sign-up) link." ]
            , signinForm model
            ]
    , buttons =
        [ signinButton "Sign in/up" model ]
    }


modalConfigOnlyForSignin : Model -> Modal.Config AppMsg.Msg
modalConfigOnlyForSignin model =
    { closeMessage = CloseModal
    , title = "Sign in with your email"
    , content =
        div []
            [ p [] [ text "Welcome to Cotoami!" ]
            , p [] [ text "Just enter your email address and we'll send you a sign-in link." ]
            , signinForm model
            ]
    , buttons =
        [ signinButton "Sign in" model ]
    }


signinForm : Model -> Html AppMsg.Msg
signinForm model =
    Html.form [ name "signin" ]
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
        ]


signinButton : String -> Model -> Html AppMsg.Msg
signinButton label model =
    button
        [ class "button button-primary"
        , disabled (not (validateEmail model.email) || model.requestProcessing)
        , onClick (AppMsg.SigninModalMsg RequestClick)
        ]
        [ if model.requestProcessing then
            text "Sending..."
          else
            text label
        ]
