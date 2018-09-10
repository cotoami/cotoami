module App.Views.AppHeader exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput, onFocus, onBlur, onSubmit)
import Html.Keyed
import Util.EventUtil exposing (onLinkButtonClick)
import Util.HtmlUtil exposing (materialIcon)
import App.Types.SearchResults exposing (SearchResults)
import App.Model exposing (Model, isNavigationEmpty)
import App.Messages
    exposing
        ( Msg
            ( HomeClick
            , OpenSigninModal
            , OpenProfileModal
            , NavigationToggle
            , SearchInputFocusChanged
            , ClearQuickSearchInput
            , QuickSearchInput
            , Search
            )
        )


view : Model -> Html Msg
view model =
    div [ id "app-header" ]
        [ div [ class "location" ]
            (model.cotonoma
                |> Maybe.map
                    (\cotonoma ->
                        [ a [ class "to-home", onLinkButtonClick HomeClick, href "/" ]
                            [ materialIcon "home" Nothing ]
                        , materialIcon "navigate_next" (Just "arrow")
                        , span [ class "cotonoma-name" ] [ text cotonoma.name ]
                        , if cotonoma.shared then
                            span [ class "shared", title "Shared" ]
                                [ materialIcon "people" Nothing ]
                          else
                            Util.HtmlUtil.none
                        , navigationToggle model
                        ]
                    )
                |> Maybe.withDefault
                    [ materialIcon "home" (Just "in-home")
                    , navigationToggle model
                    ]
            )
        , div [ class "user" ]
            (model.session
                |> Maybe.map
                    (\session ->
                        [ quickSearchForm model.searchResults
                        , a [ title "Profile", onClick OpenProfileModal ]
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


quickSearchForm : SearchResults -> Html Msg
quickSearchForm searchResults =
    Html.form
        [ class "quick-search"
        , onSubmit Search
        ]
        [ Html.Keyed.node
            "span"
            []
            [ ( toString searchResults.inputResetKey
              , input
                    [ type_ "text"
                    , class "search-input"
                    , defaultValue searchResults.query
                    , onFocus (SearchInputFocusChanged True)
                    , onBlur (SearchInputFocusChanged False)
                    , onInput QuickSearchInput
                    ]
                    []
              )
            ]
        , materialIcon "search" (Just "search")
        , if App.Types.SearchResults.hasQuery searchResults then
            a
                [ class "tool-button clear-query"
                , onLinkButtonClick ClearQuickSearchInput
                ]
                [ materialIcon "close" Nothing ]
          else
            span [] []
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
