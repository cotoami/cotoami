module App.I18n.Translations.ZhCn exposing (text)

import App.I18n.Keys exposing (TextKey(..))


text : TextKey -> String
text key =
    case key of
        Coto ->
            "投稿"

        Cotonoma ->
            "投稿室"

        MyHome ->
            "主页"

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
            "确认"

        ConfirmDeleteCoto ->
            "可以删除这件投稿吗？"

        ConfirmUnpinCoto ->
            "可以摘下这个别针吗？"

        ConfirmDisconnect ->
            "可以删除这个连接吗？"

        ConfirmCotonomatize name ->
            "可以把这投稿提升为《" ++ name ++ "》的名字的投稿室吗？"

        UnexpectedErrorOccurred ->
            "系统发生了错误。"

        SigninModal_WelcomeTitle ->
            "欢迎来到Cotoami"

        SigninModal_SignupEnabled ->
            "在Cotoami不使用密码，只通过电子邮箱进行认证。"
                ++ "请输入你可以接收的电子邮箱。"
                ++ "发送暂时的登录链接"
                ++ "（如果账户不存在，会自动注册）。"

        SigninModal_OnlyForSignin ->
            "只对用户发送登录的链接。"

        SigninModal_SendLink ->
            "发送链接"

        SigninModal_Sending ->
            "正在发送"

        SigninModal_EmailNotFound ->
            "是没有注册的电子邮箱。"

        SigninModal_SentTitle ->
            "已发送链接"

        SigninModal_SentMessage ->
            "根据不同的环境，会花费一些时间才收到电子邮件。"

        Navigation_Current ->
            "现在位置"

        Navigation_Recent ->
            "最近的投稿室"

        Navigation_Watchlist ->
            "Watchlist"

        Flow_EditorPlaceholder ->
            "写新的投稿"

        Flow_ShortcutToOpenEditor ->
            "用N键打开编辑程序"

        Flow_HideFlow ->
            "隐藏时间线"

        Flow_OpenFlow ->
            "打开时间线"

        Flow_Filter ->
            "过滤器"

        Flow_StreamView ->
            "一列"

        Flow_TileView ->
            "平铺"

        Flow_Random ->
            "Random"

        Flow_NewPosts ->
            "new posts"

        Stock_DocumentView ->
            "文档"

        Stock_GraphView ->
            "图表"

        EditorModal_Summary ->
            "摘要（可省略）"

        EditorModal_Content ->
            "内容（可利用Markdown的记法）"

        EditorModal_CotonomaName ->
            "投稿室的名字"

        EditorModal_Preview ->
            "预览"

        EditorModal_Edit ->
            "编辑"

        EditorModal_CotonomaHelp ->
            "投稿室是具有专用的时间线和留带的空间、在Cotoami里面是信息整理的单位的容器。"
                ++ "要进行讨论或收集新的主题的信息的时候，建议创建新的投稿室。"

        EditorModal_ShareCotonoma ->
            "与其他用户共享"

        EditorModal_ShareCotonomaNote ->
            "只有知道投稿室的URL的人才能访问"

        EditorModal_DuplicateCotonomaName ->
            "已有同样名字的投稿室。"

        EditorModal_TooLongForCotonomaName maxlength ->
            "投稿室的名字要符合以下的内容 需要在"
                ++ toString maxlength
                ++ " 文字以下编辑。现在的文字数: "

        ProfileModal_Title ->
            "投稿人信息"

        ProfileModal_Name ->
            "名字"

        ProfileModal_EmailAddress ->
            "电子邮箱"

        ProfileModal_Signout ->
            "退出"

        ProfileModal_Invite ->
            "邀请"

        ProfileModal_Export ->
            "导出"

        ProfileModal_Import ->
            "导入"

        InviteModal_Title ->
            "邀请到Cotoami"

        InviteModal_Message ->
            "发送含有注册用的链接的邀请邮件。"

        InviteModal_SentMessage ->
            "发送了邀请邮件: "

        InviteModal_InviteeAlreadyExists ->
            "指定的邮件地址已经注册了: "

        InviteModal_SendInvite ->
            "发送邀请邮件"

        InviteModal_Sending ->
            "正在发送"

        InviteModal_InvitesRemaining invites ->
            if invites == 1 then
                toString invites ++ " invite remaining"

            else
                toString invites ++ " invites remaining"

        CotoToolbar_Connect ->
            "连接选择中的投稿"

        CotoToolbar_Pin ->
            "用别针固定现在的投稿室"

        CotoToolbar_Edit ->
            "编辑"

        CotoToolbar_AddSubCoto ->
            "添加投稿的子项目"

        CotoToolbar_Select ->
            "选择"

        CotoToolbar_More ->
            "打开菜单列表"

        CotoToolbar_EditConnection ->
            "Edit the connection"

        CotoToolbar_Reorder ->
            "重新排列"

        CotoMenuModal_Info ->
            "信息"

        CotoMenuModal_ExploreConnections ->
            "追寻联系"

        CotoMenuModal_PinToMyHome ->
            "用别针固定主页"

        CotoMenuModal_UnpinFromMyHome ->
            "摘下主页的别针"

        CotoMenuModal_PinToCotonoma ->
            "用别针固定投稿室"

        CotoMenuModal_UnpinFromCotonoma ->
            "摘下投稿室的别针"

        CotoMenuModal_Edit ->
            "编辑"

        CotoMenuModal_AddSubCoto ->
            "添加投稿的子项目"

        CotoMenuModal_Cotonomatize ->
            "升级到投稿室"

        CotoMenuModal_Delete ->
            "删除"

        CotoMenuModal_Watch ->
            "Watch this Cotonoma"

        CotoMenuModal_Unwatch ->
            "Unwatch"

        TimelineFilterModal_Title ->
            "时间线过滤器"

        TimelineFilterModal_ExcludePinnedGraph ->
            "排除用固定别针追寻的投稿"

        TimelineFilterModal_ExcludePostsInCotonoma ->
            "排除在主页以外的投稿"

        ConnectModal_Title ->
            "建立联系"

        ConnectModal_Connect ->
            "连接"

        ConnectModal_PostAndConnect ->
            "投稿后连接"

        ConnectModal_Reverse ->
            "逆方向"

        ConnectionModal_Title ->
            "Edit Connection"

        ConnectionModal_Disconnect ->
            "解除连接"

        CotoSelection_CotosSelected count ->
            "件在选择中"

        Reorder_CloseReorderMode ->
            "完成排列"
