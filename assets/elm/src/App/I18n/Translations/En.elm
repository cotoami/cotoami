module App.I18n.Translations.En exposing (text)

import App.I18n.Keys exposing (TextKey(..))


text : TextKey -> String
text key =
    case key of
        Coto ->
            "Coto"

        Cotonoma ->
            "Cotonoma"

        Post ->
            "Post"

        Posting ->
            "Posting"

        Save ->
            "Save"

        Saving ->
            "Saving"

        UnexpectedErrorOccurred ->
            "An unexpected error has occurred."

        SigninModal_WelcomeTitle ->
            "Welcome to Cotoami!"

        SigninModal_SignupEnabled ->
            "Cotoami doesn't use passwords. Just enter your email address and we'll send you a sign-in (or sign-up) link."

        SigninModal_OnlyForSignin ->
            "Just enter your email address and we'll send you a sign-in link."

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

        Navigation_MyHome ->
            "My Home"

        Navigation_Current ->
            "Current"

        Navigation_Recent ->
            "Recent"

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
                ++ (toString maxlength)
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