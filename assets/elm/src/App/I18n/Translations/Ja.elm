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

        UnexpectedErrorOccurred ->
            "システムエラーが発生しました。"

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

        EditorModal_CotonomaName ->
            "コトノマの名前"

        EditorModal_Preview ->
            "プレビュー"

        EditorModal_Edit ->
            "編集"

        EditorModal_CotonomaHelp ->
            "コトノマは、専用のタイムラインとピン留めのスペースを持つ、Cotoamiにおいて情報整理の単位となる入れ物です。"
                ++ "新しいテーマについて議論したり情報を集めるときは専用のコトノマを作りましょう。"

        EditorModal_ShareCotonoma ->
            "他のユーザーと共有する"

        EditorModal_ShareCotonomaNote ->
            "コトノマのURLを知っている人だけがアクセスできます"

        EditorModal_DuplicateCotonomaName ->
            "同じ名前のコトノマを既に作っています。"

        EditorModal_TooLongForCotonomaName maxlength ->
            "コトノマの名前にするためには、以下の内容を "
                ++ (toString maxlength)
                ++ " 文字以下に編集する必要があります。現在の文字数: "

        ProfileModal_Title ->
            "編人情報"

        ProfileModal_Name ->
            "名前"

        ProfileModal_EmailAddress ->
            "メールアドレス"

        ProfileModal_Signout ->
            "サインアウト"

        ProfileModal_Invite ->
            "招待"

        ProfileModal_Export ->
            "エクスポート"

        ProfileModal_Import ->
            "インポート"

        InviteModal_Title ->
            "Cotoamiに招待する"

        InviteModal_Message ->
            "サインアップ用のリンクが含まれた招待メールを送ります。"

        InviteModal_SentMessage ->
            "招待メールを送信しました: "

        InviteModal_InviteeAlreadyExists ->
            "指定のメールアドレスは既に登録されています: "

        InviteModal_SendInvite ->
            "招待メールを送信"

        InviteModal_Sending ->
            "送信中"