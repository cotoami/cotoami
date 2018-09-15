module App.I18n.Translate exposing (text)

import App.I18n.Keys exposing (TextKey)
import App.I18n.Translations.En
import App.I18n.Translations.Ja


text : String -> TextKey -> String
text lang key =
    let
        translation =
            case lang of
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
