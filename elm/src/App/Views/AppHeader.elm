module App.Views.AppHeader exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Util.EventUtil exposing (onLinkButtonClick)
import Util.HtmlUtil exposing (materialIcon)
import App.Model exposing (Model, isNavigationEmpty)
import App.Messages exposing (Msg(HomeClick, OpenSigninModal, OpenProfileModal, OpenCotonomaModal, NavigationToggle))


view : Model -> Html Msg
view model =
    div [ id "app-header" ]
        [ div [ class "location" ]
            (case model.context.cotonoma of
                Nothing ->
                    [ materialIcon "home" (Just "at-home")
                    , navigationToggle model
                    ]

                Just cotonoma ->
                    [ a [ class "to-home", onLinkButtonClick HomeClick, href "/" ]
                        [ materialIcon "home" Nothing ]
                    , materialIcon "navigate_next" (Just "arrow")
                    , span [ class "cotonoma-name" ] [ text cotonoma.name ]
                    , navigationToggle model
                    ]
            )
        , (case model.context.session of
            Nothing ->
                span [] []

            Just session ->
                a
                    [ class "tool-button add-cotonoma"
                    , title "Add Cotonoma"
                    , onClick OpenCotonomaModal
                    ]
                    [ materialIcon "add_circle_outline" Nothing ]
          )
        , div [ class "user" ]
            (case model.context.session of
                Nothing ->
                    [ a
                        [ class "tool-button"
                        , title "Sign in"
                        , onClick OpenSigninModal
                        ]
                        [ materialIcon "perm_identity" Nothing ]
                    ]

                Just session ->
                    [ a [ title "Profile", onClick OpenProfileModal ]
                        [ img [ class "avatar", src session.avatarUrl ] [] ]
                    ]
            )
        ]


navigationToggle : Model -> Html Msg
navigationToggle model =
    a
        [ classList
            [ ( "tool-button", True )
            , ( "toggle-navigation", True )
            , ( "hidden", isNavigationEmpty model )
            ]
        , onClick NavigationToggle
        ]
        [ materialIcon
            (if model.navigationOpen then
                "arrow_drop_up"
             else
                "arrow_drop_down"
            )
            Nothing
        ]
