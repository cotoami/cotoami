module App.I18n.Translations.En exposing (text)

import App.I18n.Keys exposing (TextKey(..))


text : TextKey -> String
text key =
    case key of
        SigninModal_WelcomeTitle ->
            "Welcome to Cotoami!"
