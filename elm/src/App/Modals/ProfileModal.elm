module App.Modals.ProfileModal exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Util.Modal as Modal
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
                    [ div [ class "avatar-box three columns" ]
                        [ a [ href "https://gravatar.com/", target "_blank" ]
                            [ img [ class "avatar", src session.avatarUrl ] [] ]
                        ]
                    , div [ class "profile-info nine columns" ]
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
