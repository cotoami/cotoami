module App.Modals.SigninModal
    exposing
        ( Model
        , defaultModel
        , update
        , view
        , setSignupEnabled
        )

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
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
    , requestStatus : RequestStatus
    }


type RequestStatus
    = None
    | Approved
    | Rejected


defaultModel : Model
defaultModel =
    { signupEnabled = False
    , email = ""
    , requestProcessing = False
    , requestStatus = None
    }


setSignupEnabled : Bool -> Model -> Model
setSignupEnabled signupEnabled model =
    { model | signupEnabled = signupEnabled }


update : SigninModalMsg.Msg -> Model -> ( Model, Cmd SigninModalMsg.Msg )
update msg model =
    case msg of
        EmailInput content ->
            ( { model | email = content }, Cmd.none )

        RequestClick ->
            { model | requestProcessing = True }
                ! [ requestSignin model.email ]

        RequestDone (Ok _) ->
            ( { model
                | email = ""
                , requestProcessing = False
                , requestStatus = Approved
              }
            , Cmd.none
            )

        RequestDone (Err _) ->
            ( { model
                | requestProcessing = False
                , requestStatus = Rejected
              }
            , Cmd.none
            )


requestSignin : String -> Cmd SigninModalMsg.Msg
requestSignin email =
    let
        url =
            "/api/public/signin/request/" ++ email
    in
        Http.send RequestDone (Http.get url Decode.string)


view : Model -> Html AppMsg.Msg
view model =
    modalConfig model
        |> Just
        |> Modal.view "signin-modal"


modalConfig : Model -> Modal.Config AppMsg.Msg
modalConfig model =
    if model.requestStatus == Approved then
        { closeMessage = CloseModal
        , title = "Check your inbox!"
        , content =
            div [ id "signin-modal-content" ]
                [ p [] [ text "We just sent you an email with a link to access (or create) your Cotoami account." ] ]
        , buttons =
            [ button [ class "button", onClick CloseModal ] [ text "OK" ] ]
        }
    else
        if model.signupEnabled then
            modalConfigWithSignupEnabled model
        else
            modalConfigOnlyForSignin model


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
                , class "email u-full-width"
                , name "email"
                , placeholder "you@example.com"
                , value model.email
                , onInput (AppMsg.SigninModalMsg << EmailInput)
                ]
                []
            ]
        , if model.requestStatus == Rejected then
            div [ class "errors" ]
                [ span [ class "rejected" ] [ text "The email is not allowed to sign in." ] ]
          else
            div [] []
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
