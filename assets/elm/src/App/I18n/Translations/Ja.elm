module App.I18n.Translations.Ja exposing (text)

import App.I18n.Keys exposing (TextKey(..))


text : TextKey -> String
text key =
    case key of
        SigninModal_WelcomeTitle ->
            "Cotoamiへようこそ"

        SigninModal_SignupEnabled ->
            "Cotoamiではパスワードを使わずにメールアドレスだけで認証を行います。"
                ++ "あなただけが受信できるアドレスを入力して下さい。"
                ++ "サインイン用の一時リンクを送信します"
                ++ "（アカウントが存在しない場合は自動的に作成されます）。"

        SigninModal_OnlyForSignin ->
            "メンバーの方のみ、サインイン用のリンクを送信します。"

        SigninModal_SendLink ->
            "リンクを送信"

        SigninModal_Sending ->
            "送信中"

        SigninModal_EmailNotFound ->
            "登録されていないメールアドレスです。"

        SigninModal_SentTitle ->
            "リンクを送信しました"

        SigninModal_SentMessage ->
            "環境によっては、実際にメールが届くまで若干の時間がかかることがあります。"
