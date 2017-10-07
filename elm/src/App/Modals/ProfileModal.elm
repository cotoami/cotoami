module App.Modals.ProfileModal exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Util.Modal as Modal
import Util.HtmlUtil exposing (faIcon, materialIcon)
import App.Types.Session exposing (Session)
import App.Messages exposing (Msg(CloseModal, OpenInviteModal, OpenImportModal))


view : Maybe Session -> Html Msg
view maybeSession =
    Modal.view
        "profile-modal"
        (case maybeSession of
            Nothing ->
                Nothing

            Just session ->
                Just (modalConfig session)
        )


modalConfig : Session -> Modal.Config Msg
modalConfig session =
    { closeMessage = CloseModal
    , title = "Amishi Profile"
    , content =
        div [ class "profile container" ]
            [ div [ class "row" ]
                [ div
                    [ class "profile-sidebar three columns" ]
                    [ div
                        [ class "avatar-box" ]
                        [ a [ href "https://gravatar.com/", target "_blank" ]
                            [ img [ class "avatar", src session.avatarUrl ] [] ]
                        ]
                    , if session.owner then
                        div
                            [ class "owner-label" ]
                            [ faIcon "key" (Just "owner-icon")
                            , text "Owner"
                            ]
                      else
                        div [] []
                    ]
                , div
                    [ class "profile-content nine columns" ]
                    [ label [] [ text "Name" ]
                    , input
                        [ type_ "text"
                        , class "u-full-width"
                        , value session.displayName
                        , disabled True
                        ]
                        []
                    , label [] [ text "Email Address" ]
                    , input
                        [ type_ "text"
                        , class "u-full-width"
                        , value session.email
                        , disabled True
                        ]
                        []
                    ]
                ]
            , div [ class "tools" ]
                [ toolButton "Invite" "person_add"
                    [ title "Invite an amishi"
                    , onClick OpenInviteModal
                    ]
                , toolButton "Export" "cloud_download"
                    [ title "Export my data"
                    , href "/export"
                    ]
                , if session.owner then
                    toolButton "Import" "cloud_upload"
                        [ title "Import cotos and connections"
                        , onClick OpenImportModal
                        ]
                  else
                    span [] []
                ]
            ]
    , buttons =
        [ a [ class "button", href "/signout" ]
            [ text "Sign out" ]
        ]
    }


toolButton : String -> String -> List (Attribute Msg) -> Html Msg
toolButton label icon attrs =
    a
        ([ class "tool-button" ] ++ attrs)
        [ materialIcon icon Nothing
        , br [] []
        , span [ class "label" ] [ text label ]
        ]
