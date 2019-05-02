module App.I18n.Translations.Ja exposing (text)

import App.I18n.Keys exposing (TextKey(..))


text : TextKey -> String
text key =
    case key of
        Coto ->
            "コト"

        Cotonoma ->
            "コトノマ"

        MyHome ->
            "ホーム"

        Post ->
            "投稿"

        Posting ->
            "投稿中"

        Save ->
            "保存"

        Saving ->
            "保存中"

        Hide ->
            "隠す"

        Connection_LinkingPhraseInput ->
            "説明（省略可）"

        Confirm ->
            "確認"

        ConfirmDeleteCoto ->
            "このコトを削除してもよろしいですか？"

        ConfirmUnpinCoto ->
            "このピンを外してもよろしいですか？"

        ConfirmDisconnect ->
            "この接続を削除してもよろしいですか？"

        ConfirmCotonomatize name ->
            "このコトを《" ++ name ++ "》という名前のコトノマに昇格させてもよろしいですか？"

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
            "メールアドレスで登録済みの方にはサインイン用のリンクを送信します。"

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

        Navigation_Current ->
            "現在地"

        Navigation_Recent ->
            "最近のコトノマ"

        Navigation_Watchlist ->
            "ウォッチリスト"

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

        Flow_Random ->
            "ランダム"

        Flow_NewPosts ->
            "新しい投稿"

        Stock_DocumentView ->
            "ドキュメント"

        Stock_GraphView ->
            "グラフ"

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
                ++ toString maxlength
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

        InviteModal_InvitesRemaining invites ->
            "あと " ++ toString invites ++ " 人、招待できます"

        CotoToolbar_Connect ->
            "選択中のコトと接続"

        CotoToolbar_Pin ->
            "現在のコトノマにピン留め"

        CotoToolbar_Edit ->
            "編集"

        CotoToolbar_AddSubCoto ->
            "子コトを追加"

        CotoToolbar_Select ->
            "選択"

        CotoToolbar_More ->
            "メニュー一覧を開く"

        CotoToolbar_EditConnection ->
            "つながりを編集"

        CotoToolbar_Reorder ->
            "並び替え"

        CotoMenuModal_Info ->
            "情報"

        CotoMenuModal_ExploreConnections ->
            "つながりを辿る"

        CotoMenuModal_PinToMyHome ->
            "ホームにピン留め"

        CotoMenuModal_UnpinFromMyHome ->
            "ホームのピンを外す"

        CotoMenuModal_PinToCotonoma ->
            "コトノマにピン留め"

        CotoMenuModal_UnpinFromCotonoma ->
            "コトノマのピンを外す"

        CotoMenuModal_Watch ->
            "ウォッチリストに追加"

        CotoMenuModal_Unwatch ->
            "ウォッチリストから削除"

        CotoMenuModal_Edit ->
            "編集"

        CotoMenuModal_AddSubCoto ->
            "子コトを追加"

        CotoMenuModal_Cotonomatize ->
            "コトノマに昇格"

        CotoMenuModal_Delete ->
            "削除"

        TimelineFilterModal_Title ->
            "タイムラインフィルタ"

        TimelineFilterModal_ExcludePinnedGraph ->
            "ピン留めから辿れるコトを除外する"

        TimelineFilterModal_ExcludePostsInCotonoma ->
            "ホーム以外で投稿されたコトを除外する"

        ConnectModal_Title ->
            "つながりを作る"

        ConnectModal_Connect ->
            "接続"

        ConnectModal_PostAndConnect ->
            "投稿して接続"

        ConnectModal_Reverse ->
            "逆方向"

        ConnectionModal_Title ->
            "つながりを編集"

        ConnectionModal_Disconnect ->
            "接続を解除"

        CotoSelection_CotosSelected count ->
            "件のコトを選択中"

        Reorder_CloseReorderMode ->
            "並び替え完了"
