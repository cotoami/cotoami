module App.I18n.Translations.Ja exposing (text)

import App.I18n.Keys exposing (TextKey(..))


text : TextKey -> String
text key =
    case key of
        Coto ->
            "コト"

        Cotonoma ->
            "コトノマ"

        Post ->
            "投稿"

        Posting ->
            "投稿中"

        Save ->
            "保存"

        Saving ->
            "保存中"

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

        Navigation_MyHome ->
            "ホーム"

        Navigation_Current ->
            "現在地"

        Navigation_Recent ->
            "最近のコトノマ"

        Flow_EditorPlaceholder ->
            "新しいコトを書く"

        Flow_ShortcutToOpenEditor ->
            "Nキーでエディタを開く"

        Flow_HideFlow ->
            "タイムラインを隠す"

        Flow_OpenFlow ->
            "タイムラインを開く"

        Flow_Filter ->
            "フィルタ"

        Flow_StreamView ->
            "一列"

        Flow_TileView ->
            "タイル"

        EditorModal_Summary ->
            "要約（省略可）"

        EditorModal_Content ->
            "内容（Markdown記法が利用可能）"

        EditorModal_Preview ->
            "プレビュー"

        EditorModal_Edit ->
            "編集"
