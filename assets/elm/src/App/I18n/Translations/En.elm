module App.I18n.Translations.En exposing (text)

import App.I18n.Keys exposing (TextKey(..))


text : TextKey -> String
text key =
    case key of
        Coto ->
            "Coto"

        Cotonoma ->
            "Cotonoma"

        MyHome ->
            "My Home"

        Post ->
            "Post"

        Posting ->
            "Posting"

        Save ->
            "Save"

        Saving ->
            "Saving"

        Hide ->
            "Hide"

        Connection_LinkingPhraseInput ->
            "Linking phrase (optional)"

        Confirm ->
            "Confirm"

        ConfirmDeleteCoto ->
            "Are you sure you want to delete this coto?"

        ConfirmUnpinCoto ->
            "Are you sure you want to unpin this coto?"

        ConfirmDisconnect ->
            "Are you sure you want to delete this connection?"

        ConfirmCotonomatize name ->
            "You are about to promote this coto to a cotonoma named '" ++ name ++ "'"

        UnexpectedErrorOccurred ->
            "An unexpected error has occurred."

        SigninModal_WelcomeTitle ->
            "Welcome to Cotoami!"

        SigninModal_SignupEnabled ->
            "Cotoami doesn't use passwords. Just enter your email address and we'll send you a sign-in (or sign-up) link."

        SigninModal_OnlyForSignin ->
            "If you have an email address registered, just enter it and we'll send you a sign-in link."

        SigninModal_SendLink ->
            "Send a link"

        SigninModal_Sending ->
            "Sending"

        SigninModal_EmailNotFound ->
            "The email is not allowed to sign in."

        SigninModal_SentTitle ->
            "Check your inbox!"

        SigninModal_SentMessage ->
            "We just sent you an email with a link to access (or create) your Cotoami account."

        Navigation_Current ->
            "Current"

        Navigation_Recent ->
            "Recent"

        Navigation_Watchlist ->
            "Watchlist"

        Flow_EditorPlaceholder ->
            "Write your Coto in Markdown"

        Flow_ShortcutToOpenEditor ->
            "Press N key"

        Flow_HideFlow ->
            "Hide flow view"

        Flow_OpenFlow ->
            "Open flow view"

        Flow_Filter ->
            "Filter"

        Flow_StreamView ->
            "Stream View"

        Flow_TileView ->
            "Tile View"

        Flow_Random ->
            "Random"

        Flow_NewPosts ->
            "new posts"

        Stock_DocumentView ->
            "Document View"

        Stock_GraphView ->
            "Graph View"

        EditorModal_Summary ->
            "Summary (optional)"

        EditorModal_Content ->
            "Write your Coto in Markdown"

        EditorModal_CotonomaName ->
            "Cotonoma name"

        EditorModal_Preview ->
            "Preview"

        EditorModal_Edit ->
            "Edit"

        EditorModal_CotonomaHelp ->
            "A Cotonoma is a special Coto that has a dedicated chat timeline"
                ++ " where you can discuss with others about a topic described by its name."

        EditorModal_ShareCotonoma ->
            "Share it with other users."

        EditorModal_ShareCotonomaNote ->
            "Only those who know the Cotonoma URL can access it"

        EditorModal_DuplicateCotonomaName ->
            "You already have a cotonoma with this name."

        EditorModal_TooLongForCotonomaName maxlength ->
            "A cotonoma name have to be under "
                ++ toString maxlength
                ++ " characters, currently: "

        ProfileModal_Title ->
            "Amishi Profile"

        ProfileModal_Name ->
            "Name"

        ProfileModal_EmailAddress ->
            "Email Address"

        ProfileModal_Signout ->
            "Sign out"

        ProfileModal_Invite ->
            "Invite"

        ProfileModal_Export ->
            "Export"

        ProfileModal_Import ->
            "Import"

        InviteModal_Title ->
            "Invite an amishi"

        InviteModal_Message ->
            "Enter an email address to send an invitation."

        InviteModal_SentMessage ->
            "Your invitation has been sent to: "

        InviteModal_InviteeAlreadyExists ->
            "The amishi already exists: "

        InviteModal_SendInvite ->
            "Send an invite"

        InviteModal_Sending ->
            "Sending"

        InviteModal_InvitesRemaining invites ->
            if invites == 1 then
                toString invites ++ " invite remaining"

            else
                toString invites ++ " invites remaining"

        CotoToolbar_Connect ->
            "Connect from the selected cotos"

        CotoToolbar_Pin ->
            "Pin to the current cotonoma"

        CotoToolbar_Edit ->
            "Edit"

        CotoToolbar_AddSubCoto ->
            "Add a sub-coto"

        CotoToolbar_Select ->
            "Select"

        CotoToolbar_More ->
            "More"

        CotoToolbar_EditConnection ->
            "Edit the connection"

        CotoToolbar_Reorder ->
            "Reorder"

        CotoMenuModal_Info ->
            "Info"

        CotoMenuModal_ExploreConnections ->
            "Explore the connections"

        CotoMenuModal_PinToMyHome ->
            "Pin to My Home"

        CotoMenuModal_UnpinFromMyHome ->
            "Unpin from My Home"

        CotoMenuModal_PinToCotonoma ->
            "Pin to the current Cotonoma"

        CotoMenuModal_UnpinFromCotonoma ->
            "Unpin from the current Cotonoma"

        CotoMenuModal_Edit ->
            "Edit"

        CotoMenuModal_AddSubCoto ->
            "Add a sub-coto"

        CotoMenuModal_Cotonomatize ->
            "Promote to a Cotonoma"

        CotoMenuModal_Delete ->
            "Delete"

        CotoMenuModal_Watch ->
            "Watch this Cotonoma"

        CotoMenuModal_Unwatch ->
            "Unwatch"

        TimelineFilterModal_Title ->
            "Timeline Filter"

        TimelineFilterModal_ExcludePinnedGraph ->
            "Hide cotos incorporated in the pinned documents"

        TimelineFilterModal_ExcludePostsInCotonoma ->
            "Hide cotos posted in a Cotonoma other than My Home"

        ConnectModal_Title ->
            "Connect Preview"

        ConnectModal_Connect ->
            "Connect"

        ConnectModal_PostAndConnect ->
            "Post and connect"

        ConnectModal_Reverse ->
            "Reverse"

        ConnectionModal_Title ->
            "Edit Connection"

        ConnectionModal_Disconnect ->
            "Disconnect"

        CotoSelection_CotosSelected count ->
            if count == 1 then
                "coto selected"

            else
                "cotos selected"

        Reorder_CloseReorderMode ->
            "Done reordering"
