module App.I18n.Keys exposing (TextKey(..))


type TextKey
    = Coto
    | Cotonoma
    | Post
    | Posting
    | Save
    | Saving
    | UnexpectedErrorOccurred
    | SigninModal_WelcomeTitle
    | SigninModal_SignupEnabled
    | SigninModal_OnlyForSignin
    | SigninModal_SendLink
    | SigninModal_Sending
    | SigninModal_EmailNotFound
    | SigninModal_SentTitle
    | SigninModal_SentMessage
    | Navigation_MyHome
    | Navigation_Current
    | Navigation_Recent
    | Flow_EditorPlaceholder
    | Flow_ShortcutToOpenEditor
    | Flow_HideFlow
    | Flow_OpenFlow
    | Flow_Filter
    | Flow_StreamView
    | Flow_TileView
    | EditorModal_Summary
    | EditorModal_Content
    | EditorModal_CotonomaName
    | EditorModal_Preview
    | EditorModal_Edit
    | EditorModal_CotonomaHelp
    | EditorModal_ShareCotonoma
    | EditorModal_ShareCotonomaNote
    | EditorModal_DuplicateCotonomaName
    | EditorModal_TooLongForCotonomaName Int
    | ProfileModal_Title
    | ProfileModal_Name
    | ProfileModal_EmailAddress
    | ProfileModal_Signout
    | ProfileModal_Invite
    | ProfileModal_Export
    | ProfileModal_Import
    | InviteModal_Title
    | InviteModal_Message
    | InviteModal_SentMessage
    | InviteModal_InviteeAlreadyExists
    | InviteModal_SendInvite
    | InviteModal_Sending