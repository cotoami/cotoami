module App.Modals.ProfileModal exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Util.Modal as Modal
import Util.HtmlUtil exposing (faIcon)
import App.Types.Session exposing (Session)
import App.Messages exposing (Msg(CloseModal))


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
        div []
            [ div [ class "profile container" ]
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
                ]
            ]
    , buttons =
        [ a [ class "button", href "/export" ]
            [ text "Export my data" ]
        , a [ class "button", href "/signout" ]
            [ text "Sign out" ]
        ]
    }
