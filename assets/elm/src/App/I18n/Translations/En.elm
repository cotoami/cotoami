module App.I18n.Translations.En exposing (text)

import App.I18n.Keys exposing (TextKey(..))


text : TextKey -> String
text key =
    case key of
        SigninModal_WelcomeTitle ->
            "Welcome to Cotoami!"

        SigninModal_SignupEnabled ->
            "Cotoami doesn't use passwords. Just enter your email address and we'll send you a sign-in (or sign-up) link."

        SigninModal_OnlyForSignin ->
            "Just enter your email address and we'll send you a sign-in link."

        SigninModal_SendLink ->
            "Send a link"

        SigninModal_Sending ->
            "Sending"

        SigninModal_EmailNotFound ->
            "The email is not allowed to sign in."

        SigninModal_SentTitle ->
            "Check your inbox!"

        SigninModal_SentMessage ->
            "We just sent you an email with a link to access (or create) your Cotoami account."
