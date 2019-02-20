module App.Modals.ProfileModal exposing (update, view)

import App.I18n.Keys as I18nKeys
import App.Messages as AppMsg exposing (Msg(CloseModal))
import App.Modals.InviteModal
import App.Modals.ProfileModalMsg as ProfileModalMsg exposing (Msg(..))
import App.Ports.ImportFile
import App.Submodels.Context exposing (Context)
import App.Submodels.Modals exposing (Modal(InviteModal), Modals)
import App.Types.Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Utils.HtmlUtil exposing (faIcon, materialIcon)
import Utils.Modal
import Utils.StringUtil
import Utils.UpdateUtil exposing (..)


type alias UpdateModel model =
    Modals { model | inviteModal : App.Modals.InviteModal.Model }


update : Context context -> ProfileModalMsg.Msg -> UpdateModel model -> ( UpdateModel model, Cmd AppMsg.Msg )
update context msg model =
    case msg of
        OpenInviteModal ->
            { model | inviteModal = App.Modals.InviteModal.defaultModel }
                |> App.Submodels.Modals.openModal InviteModal
                |> withCmd (\_ -> App.Modals.InviteModal.sendInit)

        SelectImportFile ->
            ( model, App.Ports.ImportFile.selectImportFile () )


view : Context context -> Session -> Html AppMsg.Msg
view context session =
    Utils.Modal.view "profile-modal" (modalConfig context session)


modalConfig : Context context -> Session -> Utils.Modal.Config AppMsg.Msg
modalConfig context session =
    { closeMessage = CloseModal
    , title = text (context.i18nText I18nKeys.ProfileModal_Title)
    , content =
        div [ class "profile container" ]
            [ div [ class "row" ]
                [ div
                    [ class "profile-sidebar three columns" ]
                    [ div
                        [ class "avatar-box" ]
                        [ a [ href "https://gravatar.com/", target "_blank" ]
                            [ img [ class "avatar", src session.amishi.avatarUrl ] [] ]
                        ]
                    , if session.amishi.owner then
                        div
                            [ class "owner-label" ]
                            [ faIcon "key" (Just "owner-icon")
                            , text "Owner"
                            ]

                      else
                        Utils.HtmlUtil.none
                    ]
                , div
                    [ class "profile-content nine columns" ]
                    [ label [] [ text (context.i18nText I18nKeys.ProfileModal_Name) ]
                    , input
                        [ type_ "text"
                        , class "u-full-width"
                        , value session.amishi.displayName
                        , disabled True
                        ]
                        []
                    , session.amishi.email
                        |> Maybe.map (emailField context)
                        |> Maybe.withDefault Utils.HtmlUtil.none
                    , session.amishi.authProvider
                        |> Maybe.map (oauthField context)
                        |> Maybe.withDefault Utils.HtmlUtil.none
                    ]
                ]
            , div [ class "tools" ]
                [ toolButton (context.i18nText I18nKeys.ProfileModal_Invite)
                    "person_add"
                    [ onClick (AppMsg.ProfileModalMsg OpenInviteModal) ]
                , toolButton (context.i18nText I18nKeys.ProfileModal_Export)
                    "cloud_download"
                    [ href "/export" ]
                , if session.amishi.owner then
                    toolButton (context.i18nText I18nKeys.ProfileModal_Import)
                        "cloud_upload"
                        [ onClick (AppMsg.ProfileModalMsg SelectImportFile) ]

                  else
                    Utils.HtmlUtil.none
                ]
            ]
    , buttons =
        [ a [ class "button", href "/signout" ]
            [ text (context.i18nText I18nKeys.ProfileModal_Signout) ]
        ]
    }


emailField : Context context -> String -> Html AppMsg.Msg
emailField context email =
    div [ class "field" ]
        [ label [] [ text (context.i18nText I18nKeys.ProfileModal_EmailAddress) ]
        , input
            [ type_ "text"
            , class "u-full-width"
            , value email
            , disabled True
            ]
            []
        ]


oauthField : Context context -> String -> Html AppMsg.Msg
oauthField context provider =
    div [ class "field" ]
        [ label [] [ text "OAuth" ]
        , input
            [ type_ "text"
            , class "u-full-width"
            , value (Utils.StringUtil.capitalize provider)
            , disabled True
            ]
            []
        ]


toolButton : String -> String -> List (Attribute AppMsg.Msg) -> Html AppMsg.Msg
toolButton label icon attrs =
    a
        ([ class "tool-button" ] ++ attrs)
        [ materialIcon icon Nothing
        , br [] []
        , span [ class "label" ] [ text label ]
        ]
