module App.Views.SearchResults exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onFocus, onBlur, onInput)
import Html.Keyed
import Utils.EventUtil exposing (onLinkButtonClick)
import Utils.HtmlUtil exposing (materialIcon)
import Utils.DateUtil
import App.Types.Post exposing (Post)
import App.Types.Graph exposing (Graph)
import App.Types.SearchResults exposing (SearchResults)
import App.Messages exposing (..)
import App.Submodels.Context exposing (Context)
import App.Views.Coto
import App.Views.Post
import App.Markdown


view : Context a -> Graph -> SearchResults -> Html Msg
view context graph model =
    div [ id "search-results" ]
        [ div
            [ class "column-header" ]
            [ span [ class "description", title "Search results" ]
                [ materialIcon "search" Nothing
                ]
            , span [ class "search-in-narrow-viewport" ]
                [ Html.Keyed.node
                    "span"
                    []
                    [ ( toString model.inputResetKey
                      , input
                            [ type_ "text"
                            , class "search-input"
                            , defaultValue model.query
                            , onFocus (SearchInputFocusChanged True)
                            , onBlur (SearchInputFocusChanged False)
                            , onInput SearchInput
                            ]
                            []
                      )
                    ]
                , a
                    [ class "tool-button search"
                    , onLinkButtonClick Search
                    ]
                    [ materialIcon "search" Nothing ]
                ]
            ]
        , div
            [ class "column-body" ]
            [ if model.loading then
                div [ class "loading-overlay" ] []
              else
                div [] []
            , model.posts
                |> List.map
                    (\post ->
                        ( Maybe.withDefault "" post.cotoId
                        , postDiv context graph post
                        )
                    )
                |> Html.Keyed.node "div" [ class "posts" ]
            ]
        ]


postDiv : Context a -> Graph -> Post -> Html Msg
postDiv context graph post =
    let
        elementId =
            "search-result-" ++ (Maybe.withDefault "none" post.cotoId)
    in
        div
            (App.Views.Post.postDivAttrs context graph elementId post)
            [ div
                [ class "coto-inner" ]
                [ App.Views.Post.headerDiv context graph elementId post
                , post.cotoId
                    |> Maybe.map (\cotoId -> App.Views.Coto.parentsDiv graph Nothing cotoId)
                    |> Maybe.withDefault (div [] [])
                , if post.isCotonoma then
                    Utils.HtmlUtil.none
                  else
                    App.Views.Post.authorDiv context post
                , App.Views.Coto.bodyDiv context elementId App.Markdown.markdown post
                , footerDiv context post
                , App.Views.Coto.subCotosButtonDiv graph Nothing post.cotoId
                ]
            ]


footerDiv : Context a -> Post -> Html Msg
footerDiv context post =
    post.postedAt
        |> Maybe.map
            (\postedAt ->
                let
                    lang =
                        context.session
                            |> Maybe.map (\session -> session.lang)
                            |> Maybe.withDefault ""

                    day =
                        Utils.DateUtil.formatDay lang postedAt

                    time =
                        Utils.DateUtil.format "en_us" "%H:%M:%S" postedAt
                in
                    div
                        [ class "post-footer" ]
                        [ span [ class "posted-at" ]
                            [ span [ class "day" ] [ text day ]
                            , span [ class "time" ] [ text time ]
                            ]
                        ]
            )
        |> Maybe.withDefault (span [] [])
