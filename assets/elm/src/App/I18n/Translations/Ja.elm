module App.I18n.Translations.Ja exposing (text)

import App.I18n.Keys exposing (TextKey(..))


text : TextKey -> String
text key =
    case key of
        SigninModal_SignupTitle ->
            "サインアップ / サインイン"
