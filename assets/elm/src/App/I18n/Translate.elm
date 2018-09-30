module App.I18n.Translate exposing (text)

import App.I18n.Keys exposing (TextKey)
import App.I18n.Translations.En
import App.I18n.Translations.Ja
import App.I18n.Translations.Uk
import App.I18n.Translations.Ru
import App.I18n.Translations.ZhCn
import App.I18n.Translations.ZhTw


text : String -> TextKey -> String
text lang key =
    let
        translation =
            case lang of
                "en" ->
                    App.I18n.Translations.En.text

                "uk" ->
                    App.I18n.Translations.Uk.text

                "uk-UA" ->
                    App.I18n.Translations.Uk.text

                "ru" ->
                    App.I18n.Translations.Ru.text

                "ru-RU" ->
                    App.I18n.Translations.Ru.text

                "zh" ->
                    App.I18n.Translations.ZhCn.text

                "zh-CN" ->
                    App.I18n.Translations.ZhCn.text

                "zh-TW" ->
                    App.I18n.Translations.ZhTw.text

                "zh-HK" ->
                    App.I18n.Translations.ZhTw.text

                "ja" ->
                    App.I18n.Translations.Ja.text

                "ja-jp" ->
                    App.I18n.Translations.Ja.text

                _ ->
                    App.I18n.Translations.En.text
    in
        translation key
