module App.I18n.Translate exposing (text)

import App.I18n.Keys exposing (TextKey)
import App.I18n.Translations.En
import App.I18n.Translations.Ja
import App.I18n.Translations.Ua

text : String -> TextKey -> String
text lang key =
    let
        translation =
            case lang of
                "ua" ->
                    App.I18n.Translations.Ua.text

                "en" ->
                    App.I18n.Translations.En.text

                "ja" ->
                    App.I18n.Translations.Ja.text

                "ja-jp" ->
                    App.I18n.Translations.Ja.text

                _ ->
                    App.I18n.Translations.En.text
    in
        translation key
