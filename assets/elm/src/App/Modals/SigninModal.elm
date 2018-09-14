module App.Modals.SigninModal
    exposing
        ( Model
        , initModel
        , update
        , view
        , setSignupEnabled
        )

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode as Decode
import Utils.StringUtil exposing (validateEmail)
import Utils.UpdateUtil exposing (withCmd, withoutCmd, addCmd)
import Utils.Modal as Modal
import App.I18n.Keys as I18nKeys
import App.Submodels.Context exposing (Context)
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


initModel : Bool -> Model
initModel signupEnabled =
    { signupEnabled = signupEnabled
    , email = ""
    , requestProcessing = False
    , requestStatus = None
    }


setSignupEnabled : Bool -> Model -> Model
setSignupEnabled signupEnabled model =
    { model | signupEnabled = signupEnabled }


update : SigninModalMsg.Msg -> Model -> ( Model, Cmd AppMsg.Msg )
update msg model =
    case msg of
        EmailInput content ->
            { model | email = content } |> withoutCmd

        RequestClick ->
            { model | requestProcessing = True }
                |> withCmd (\model -> requestSignin model.email)

        RequestDone (Ok _) ->
            { model
                | email = ""
                , requestProcessing = False
                , requestStatus = Approved
            }
                |> withoutCmd

        RequestDone (Err _) ->
            { model
                | requestProcessing = False
                , requestStatus = Rejected
            }
                |> withoutCmd


requestSignin : String -> Cmd AppMsg.Msg
requestSignin email =
    let
        url =
            "/api/public/signin/request/" ++ email
    in
        Http.send
            (AppMsg.SigninModalMsg << RequestDone)
            (Http.get url Decode.string)


view : Context context -> Model -> Html AppMsg.Msg
view context model =
    modalConfig context model
        |> Just
        |> Modal.view "signin-modal"


modalConfig : Context context -> Model -> Modal.Config AppMsg.Msg
modalConfig context model =
    if model.requestStatus == Approved then
        { closeMessage = CloseModal
        , title = text "Check your inbox!"
        , content =
            div [ id "signin-modal-content" ]
                [ p [] [ text "We just sent you an email with a link to access (or create) your Cotoami account." ] ]
        , buttons =
            [ button [ class "button", onClick CloseModal ] [ text "OK" ] ]
        }
    else if model.signupEnabled then
        modalConfigWithSignupEnabled context model
    else
        modalConfigOnlyForSignin model


modalConfigWithSignupEnabled : Context context -> Model -> Modal.Config AppMsg.Msg
modalConfigWithSignupEnabled context model =
    { closeMessage = CloseModal
    , title = text (context.i18nText I18nKeys.SigninModal_SignupTitle)
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
    , title = text "Sign in with your email"
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
            div [ class "error" ]
                [ span [ class "message" ] [ text "The email is not allowed to sign in." ] ]
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
