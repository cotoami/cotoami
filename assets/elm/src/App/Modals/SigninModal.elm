module App.Modals.SigninModal
    exposing
        ( Model
        , defaultModel
        , initModel
        , update
        , view
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
import App.Types.Session exposing (AuthSettings)
import App.Submodels.Context exposing (Context)
import App.Messages as AppMsg exposing (Msg(CloseModal))
import App.Modals.SigninModalMsg as SigninModalMsg exposing (Msg(..))


type alias Model =
    { authSettings : AuthSettings
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
    { authSettings = App.Types.Session.defaultAuthSettings
    , email = ""
    , requestProcessing = False
    , requestStatus = None
    }


initModel : AuthSettings -> Model
initModel authSettings =
    { authSettings = authSettings
    , email = ""
    , requestProcessing = False
    , requestStatus = None
    }


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
        , title = text (context.i18nText I18nKeys.SigninModal_SentTitle)
        , content =
            div [ id "signin-modal-content" ]
                [ p [] [ text (context.i18nText I18nKeys.SigninModal_SentMessage) ] ]
        , buttons =
            [ button [ class "button", onClick CloseModal ] [ text "OK" ] ]
        }
    else if model.authSettings.signupEnabled then
        modalConfigWithSignupEnabled context model
    else
        modalConfigOnlyForSignin context model


modalConfigWithSignupEnabled : Context context -> Model -> Modal.Config AppMsg.Msg
modalConfigWithSignupEnabled context model =
    { closeMessage = CloseModal
    , title = welcomeTitle context
    , content =
        div []
            [ p [] [ text (context.i18nText I18nKeys.SigninModal_SignupEnabled) ]
            , signinForm context model
            ]
    , buttons =
        [ sendLinkButton context model ]
    }


modalConfigOnlyForSignin : Context context -> Model -> Modal.Config AppMsg.Msg
modalConfigOnlyForSignin context model =
    { closeMessage = CloseModal
    , title = welcomeTitle context
    , content =
        div []
            [ p [] [ text (context.i18nText I18nKeys.SigninModal_OnlyForSignin) ]
            , signinForm context model
            ]
    , buttons =
        [ sendLinkButton context model ]
    }


welcomeTitle : Context context -> Html AppMsg.Msg
welcomeTitle context =
    span []
        [ img [ class "logo", src "/images/logo/logomark.svg" ] []
        , text (context.i18nText I18nKeys.SigninModal_WelcomeTitle)
        ]


signinForm : Context context -> Model -> Html AppMsg.Msg
signinForm context model =
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
                [ span [ class "message" ]
                    [ text (context.i18nText I18nKeys.SigninModal_EmailNotFound) ]
                ]
          else
            div [] []
        ]


sendLinkButton : Context context -> Model -> Html AppMsg.Msg
sendLinkButton context model =
    button
        [ class "button button-primary"
        , disabled (not (validateEmail model.email) || model.requestProcessing)
        , onClick (AppMsg.SigninModalMsg RequestClick)
        ]
        [ if model.requestProcessing then
            text ((context.i18nText I18nKeys.SigninModal_Sending) ++ "...")
          else
            text (context.i18nText I18nKeys.SigninModal_SendLink)
        ]
