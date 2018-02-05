module App.Views.SearchResults exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import App.Types.Context exposing (Context)
import App.Types.Post exposing (Post)
import App.Types.Graph exposing (Graph)
import App.Types.SearchResults exposing (SearchResults)
import App.Messages exposing (..)
import App.Views.Coto
import App.Views.Post
import App.Markdown


view : SearchResults -> Html Msg
view model =
    div [ id "search-results" ]
        [ if model.loading then
            div [ class "loading-overlay" ] []
          else
            div [] []
        ]


postDiv : Context -> Graph -> Post -> Html Msg
postDiv context graph post =
    let
        elementId =
            "search-result-" ++ (Maybe.withDefault "none" post.cotoId)
    in
        div
            (App.Views.Post.postDivAttrs context elementId post)
            [ div
                [ class "coto-inner" ]
                [ App.Views.Post.headerDiv context graph elementId post
                , post.cotoId
                    |> Maybe.map (\cotoId -> App.Views.Coto.parentsDiv graph Nothing cotoId)
                    |> Maybe.withDefault (div [] [])
                , if post.asCotonoma then
                    div [] []
                  else
                    App.Views.Post.authorDiv context post
                , App.Views.Coto.bodyDiv context elementId App.Markdown.markdown post
                , App.Views.Coto.subCotosEllipsisDiv post.cotoId graph
                ]
            ]
