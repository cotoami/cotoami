module App.Views.AppHeader exposing
    ( navigationToggle
    , quickSearchForm
    , update
    , view
    )

import App.Messages as AppMsg
import App.Model exposing (Model)
import App.Server.Post
import App.Submodels.Context exposing (Context)
import App.Submodels.LocalCotos
import App.Types.SearchResults exposing (SearchResults)
import App.Views.AppHeaderMsg as AppHeaderMsg exposing (Msg(..))
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onBlur, onClick, onFocus, onInput, onSubmit)
import Html.Keyed
import Utils.EventUtil exposing (onLinkButtonClick)
import Utils.HtmlUtil exposing (materialIcon)
import Utils.StringUtil
import Utils.UpdateUtil exposing (..)


view : Model -> Html AppMsg.Msg
view model =
    div [ id "app-header" ]
        [ div [ class "app-info" ]
            [ a
                [ title "View app info"
                , onClick AppMsg.OpenAppInfoModal
                ]
                [ img [ class "app-icon", src "/images/logo/logomark.svg" ] [] ]
            ]
        , div [ class "location" ]
            (model.cotonoma
                |> Maybe.map
                    (\cotonoma ->
                        [ a [ class "to-home", onLinkButtonClick AppMsg.MoveToHome, href "/" ]
                            [ materialIcon "home" Nothing ]
                        , materialIcon "navigate_next" (Just "arrow")
                        , span [ class "cotonoma-name" ] [ text cotonoma.name ]
                        , if cotonoma.shared then
                            span [ class "shared", title "Shared" ]
                                [ materialIcon "people" Nothing ]

                          else
                            Utils.HtmlUtil.none
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
                        , a
                            [ title "Profile"
                            , onClick AppMsg.OpenProfileModal
                            ]
                            [ img [ class "avatar", src session.amishi.avatarUrl ] [] ]
                        ]
                    )
                |> Maybe.withDefault
                    [ a
                        [ class "tool-button"
                        , title "Sign in"
                        , onClick AppMsg.OpenSigninModal
                        ]
                        [ materialIcon "perm_identity" Nothing ]
                    ]
            )
        ]


quickSearchForm : SearchResults -> Html AppMsg.Msg
quickSearchForm searchResults =
    Html.form
        [ class "quick-search"
        , onSubmit AppMsg.Search
        ]
        [ Html.Keyed.node
            "span"
            []
            [ ( toString searchResults.inputResetKey
              , input
                    [ type_ "text"
                    , class "search-input"
                    , defaultValue searchResults.query
                    , onFocus (AppMsg.SearchInputFocusChanged True)
                    , onBlur (AppMsg.SearchInputFocusChanged False)
                    , onInput (AppMsg.AppHeaderMsg << QuickSearchInput)
                    ]
                    []
              )
            ]
        , materialIcon "search" (Just "search")
        , if App.Types.SearchResults.hasQuery searchResults then
            a
                [ class "tool-button clear-query"
                , onLinkButtonClick (AppMsg.AppHeaderMsg ClearQuickSearchInput)
                ]
                [ materialIcon "close" Nothing ]

          else
            Utils.HtmlUtil.none
        ]


navigationToggle : Model -> Html AppMsg.Msg
navigationToggle model =
    span
        [ classList
            [ ( "toggle-navigation", True )
            , ( "hidden", App.Submodels.LocalCotos.isNavigationEmpty model )
            ]
        ]
        [ a
            [ class "tool-button"
            , onClick AppMsg.ToggleNavInNarrowViewport
            ]
            [ materialIcon
                (if model.narrowViewport.navOpen then
                    "arrow_drop_up"

                 else
                    "arrow_drop_down"
                )
                Nothing
            ]
        , if App.Submodels.Context.anyUnreadCotos model then
            materialIcon "fiber_manual_record" (Just "unread")

          else
            Utils.HtmlUtil.none
        ]


type alias UpdateModel model =
    { model | searchResults : SearchResults }


update : Context context -> AppHeaderMsg.Msg -> UpdateModel model -> ( UpdateModel model, Cmd AppMsg.Msg )
update context msg model =
    case msg of
        ClearQuickSearchInput ->
            { model | searchResults = App.Types.SearchResults.clearQuery model.searchResults }
                |> withoutCmd

        QuickSearchInput query ->
            { model | searchResults = App.Types.SearchResults.setQuerying query model.searchResults }
                |> withCmdIf
                    (\_ -> Utils.StringUtil.isNotBlank query)
                    (\_ -> App.Server.Post.search query)
