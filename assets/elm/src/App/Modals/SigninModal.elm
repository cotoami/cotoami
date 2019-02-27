module App.Modals.SigninModal exposing
    ( Model
    , defaultModel
    , initModel
    , update
    , view
    )

import App.I18n.Keys as I18nKeys
import App.Messages as AppMsg exposing (Msg(CloseModal))
import App.Modals.SigninModalMsg as SigninModalMsg exposing (Msg(..))
import App.Submodels.Context exposing (Context)
import App.Types.Session exposing (AuthSettings)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode as Decode
import Utils.HtmlUtil exposing (faIcon)
import Utils.Modal
import Utils.StringUtil exposing (validateEmail)
import Utils.UpdateUtil exposing (..)


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


view : Context context -> Model -> Html AppMsg.Msg
view context model =
    model
        |> modalConfig context
        |> Utils.Modal.view "signin-modal"


modalConfig : Context context -> Model -> Utils.Modal.Config AppMsg.Msg
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

    else
        { closeMessage = CloseModal
        , title = welcomeTitle context
        , content =
            div []
                [ oauthSigninDiv context model
                , emailSigninDiv context model
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


oauthSigninDiv : Context context -> Model -> Html AppMsg.Msg
oauthSigninDiv context model =
    if List.isEmpty model.authSettings.oauthProviders then
        Utils.HtmlUtil.none

    else
        div [ class "oauth-signin" ]
            [ div [ class "oauth-buttons" ]
                (model.authSettings.oauthProviders
                    |> List.map oauthButton
                )
            , hr [] []
            ]


oauthButton : String -> Html AppMsg.Msg
oauthButton provider =
    case provider of
        "google" ->
            div [ class "oauth-button-container" ]
                [ a [ class "button", href "/auth/google" ]
                    [ faIcon "google" Nothing
                    , text "Sign in with Google"
                    ]
                ]

        "github" ->
            div [ class "oauth-button-container" ]
                [ a [ class "button", href "/auth/github" ]
                    [ faIcon "github" Nothing
                    , text "Sign in with GitHub"
                    ]
                ]

        "patreon" ->
            div [ class "oauth-button-container" ]
                [ a [ class "button", href "/auth/patreon" ]
                    [ img [ class "patreon-icon", src "/images/Patreon-Icon_Primary.png" ] []
                    , text "Sign in with Patreon"
                    ]
                ]

        _ ->
            Utils.HtmlUtil.none


emailSigninDiv : Context context -> Model -> Html AppMsg.Msg
emailSigninDiv context model =
    div [ class "email-signin" ]
        [ if model.authSettings.signupEnabled then
            p [] [ text (context.i18nText I18nKeys.SigninModal_SignupEnabled) ]

          else
            p [] [ text (context.i18nText I18nKeys.SigninModal_OnlyForSignin) ]
        , signinForm context model
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
            Utils.HtmlUtil.none
        ]


sendLinkButton : Context context -> Model -> Html AppMsg.Msg
sendLinkButton context model =
    button
        [ class "button button-primary"
        , disabled (not (validateEmail model.email) || model.requestProcessing)
        , onClick (AppMsg.SigninModalMsg RequestClick)
        ]
        [ if model.requestProcessing then
            text (context.i18nText I18nKeys.SigninModal_Sending ++ "...")

          else
            text (context.i18nText I18nKeys.SigninModal_SendLink)
        ]


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
