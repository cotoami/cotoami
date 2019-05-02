module App.I18n.Translations.ZhTw exposing (text)

import App.I18n.Keys exposing (TextKey(..))


text : TextKey -> String
text key =
    case key of
        Coto ->
            "投稿"

        Cotonoma ->
            "投稿室"

        MyHome ->
            "主頁"

        Post ->
            "投稿"

        Posting ->
            "投稿中"

        Save ->
            "保存"

        Saving ->
            "保存中"

        Hide ->
            "Hide"

        Connection_LinkingPhraseInput ->
            "Linking phrase (optional)"

        Confirm ->
            "確認"

        ConfirmDeleteCoto ->
            "可以删除這件投稿嗎？"

        ConfirmUnpinCoto ->
            "可以摘下這個別針嗎？"

        ConfirmDisconnect ->
            "可以删除這個連接嗎？"

        ConfirmCotonomatize name ->
            "可以把這投稿提升為《“++ name ++”》的名字的投稿室嗎？"

        UnexpectedErrorOccurred ->
            "系統發生了錯誤。"

        SigninModal_WelcomeTitle ->
            "歡迎來到Cotoami"

        SigninModal_SignupEnabled ->
            "在Cotoami不使用密碼，只通過電子郵箱進行認證。"
                ++ "請輸入你可以接收的電子郵箱。"
                ++ "發送暫時的登入連結"
                ++ "（如果帳戶不存在，會自動注册）。"

        SigninModal_OnlyForSignin ->
            "只對用戶發送登入的連結。"

        SigninModal_SendLink ->
            "發送連結"

        SigninModal_Sending ->
            "正在發送"

        SigninModal_EmailNotFound ->
            "是沒有註冊的電子郵箱。"

        SigninModal_SentTitle ->
            "已發送連結"

        SigninModal_SentMessage ->
            "根據不同的環境，會花費一些時間才收到電子郵件。"

        Navigation_Current ->
            "現在位置"

        Navigation_Recent ->
            "最近的投稿室"

        Navigation_Watchlist ->
            "Watchlist"

        Flow_EditorPlaceholder ->
            "寫新的投稿"

        Flow_ShortcutToOpenEditor ->
            "用N鍵打開編輯程式"

        Flow_HideFlow ->
            "隱藏時間線"

        Flow_OpenFlow ->
            "打開時間線"

        Flow_Filter ->
            "篩檢程式"

        Flow_StreamView ->
            "一列"

        Flow_TileView ->
            "平铺"

        Flow_Random ->
            "Random"

        Flow_NewPosts ->
            "new posts"

        Stock_DocumentView ->
            "檔案"

        Stock_GraphView ->
            "圖表"

        EditorModal_Summary ->
            "摘要（可省略）"

        EditorModal_Content ->
            "內容（可利用Markdown的記法）"

        EditorModal_CotonomaName ->
            "投稿室的名字"

        EditorModal_Preview ->
            "預覽"

        EditorModal_Edit ->
            "編輯"

        EditorModal_CotonomaHelp ->
            "投稿室是具有專用的時間線和留帶的空間、在Cotoami裡面是資訊整理的組織的容器。"
                ++ "要進行討論或收集新的主題的資訊的時候，建議創建新的投稿室。"

        EditorModal_ShareCotonoma ->
            "與其他用戶共亯"

        EditorModal_ShareCotonomaNote ->
            "只有知道投稿室的URL的人才能訪問"

        EditorModal_DuplicateCotonomaName ->
            "已有同樣名字的投稿室。"

        EditorModal_TooLongForCotonomaName maxlength ->
            "投稿室的名字要符合以下的內容 需要在"
                ++ toString maxlength
                ++ " 文字以下編輯。現在的文字數: "

        ProfileModal_Title ->
            "投稿人資訊"

        ProfileModal_Name ->
            "名字"

        ProfileModal_EmailAddress ->
            "電子郵箱"

        ProfileModal_Signout ->
            "退出"

        ProfileModal_Invite ->
            "邀請"

        ProfileModal_Export ->
            "匯出"

        ProfileModal_Import ->
            "導入"

        InviteModal_Title ->
            "邀請到Cotoami"

        InviteModal_Message ->
            "發送含有注册用的連結的邀請郵件。"

        InviteModal_SentMessage ->
            "發送了邀請郵件: "

        InviteModal_InviteeAlreadyExists ->
            "指定的郵寄地址已經注册了: "

        InviteModal_SendInvite ->
            "發送邀請郵件"

        InviteModal_Sending ->
            "正在發送"

        InviteModal_InvitesRemaining invites ->
            if invites == 1 then
                toString invites ++ " invite remaining"

            else
                toString invites ++ " invites remaining"

        CotoToolbar_Connect ->
            "連接選擇中的投稿"

        CotoToolbar_Pin ->
            "用別針固定現在的投稿室"

        CotoToolbar_Edit ->
            "編輯"

        CotoToolbar_AddSubCoto ->
            "添加投稿的子项目"

        CotoToolbar_Select ->
            "選擇"

        CotoToolbar_More ->
            "打開選單清單"

        CotoToolbar_EditConnection ->
            "Edit the connection"

        CotoToolbar_Reorder ->
            "重新排列"

        CotoMenuModal_Info ->
            "資訊"

        CotoMenuModal_ExploreConnections ->
            "追尋聯系"

        CotoMenuModal_PinToMyHome ->
            "用別針固定主頁"

        CotoMenuModal_UnpinFromMyHome ->
            "摘下主頁的別針"

        CotoMenuModal_PinToCotonoma ->
            "用別針固定投稿室"

        CotoMenuModal_UnpinFromCotonoma ->
            "摘下投稿室的别针"

        CotoMenuModal_Edit ->
            "編輯"

        CotoMenuModal_AddSubCoto ->
            "添加投稿的子项目"

        CotoMenuModal_Cotonomatize ->
            "陞級到投稿室"

        CotoMenuModal_Delete ->
            "删除"

        CotoMenuModal_Watch ->
            "Watch this Cotonoma"

        CotoMenuModal_Unwatch ->
            "Unwatch"

        TimelineFilterModal_Title ->
            "時間線篩檢程式"

        TimelineFilterModal_ExcludePinnedGraph ->
            "排除用固定別針追尋的投稿"

        TimelineFilterModal_ExcludePostsInCotonoma ->
            "排除在主頁以外的投稿"

        ConnectModal_Title ->
            "建立聯系"

        ConnectModal_Connect ->
            "連接"

        ConnectModal_PostAndConnect ->
            "投稿後連接"

        ConnectModal_Reverse ->
            "逆方向"

        ConnectionModal_Title ->
            "Edit Connection"

        ConnectionModal_Disconnect ->
            "解除連接"

        CotoSelection_CotosSelected count ->
            "件在選擇中"

        Reorder_CloseReorderMode ->
            "完成排列"
