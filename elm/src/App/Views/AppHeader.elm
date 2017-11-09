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
            (model.context.cotonoma
                |> Maybe.map
                    (\cotonoma ->
                        [ a [ class "to-home", onLinkButtonClick HomeClick, href "/" ]
                            [ materialIcon "home" Nothing ]
                        , materialIcon "navigate_next" (Just "arrow")
                        , span [ class "cotonoma-name" ] [ text cotonoma.name ]
                        , navigationToggle model
                        ]
                    )
                |> Maybe.withDefault
                    [ materialIcon "home" (Just "in-home")
                    , navigationToggle model
                    ]
            )
        , model.context.session
            |> Maybe.map
                (\session ->
                    a
                        [ class "tool-button add-cotonoma"
                        , title "Add Cotonoma"
                        , onClick OpenCotonomaModal
                        ]
                        [ materialIcon "add_circle_outline" Nothing ]
                )
            |> Maybe.withDefault (span [] [])
        , div [ class "user" ]
            (model.context.session
                |> Maybe.map
                    (\session ->
                        [ a [ title "Profile", onClick OpenProfileModal ]
                            [ img [ class "avatar", src session.avatarUrl ] [] ]
                        ]
                    )
                |> Maybe.withDefault
                    [ a
                        [ class "tool-button"
                        , title "Sign in"
                        , onClick OpenSigninModal
                        ]
                        [ materialIcon "perm_identity" Nothing ]
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
