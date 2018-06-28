module App.Modals.TimelineFilterModal exposing (update, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onCheck)
import Util.Modal as Modal
import Util.UpdateUtil exposing (withCmd, withoutCmd, addCmd)
import Util.HtmlUtil exposing (materialIcon)
import App.Messages as AppMsg exposing (Msg(CloseModal))
import App.Modals.TimelineFilterModalMsg as TimelineFilterModalMsg exposing (Msg(..))
import App.Types.Context exposing (Context)
import App.Types.Timeline exposing (Filter)
import App.Server.Post


update : Context -> TimelineFilterModalMsg.Msg -> Filter -> ( Filter, Cmd AppMsg.Msg )
update context msg filter =
    case msg of
        ExcludePinnedGraphOptionCheck check ->
            { filter | excludePinnedGraph = check }
                |> withCmd (\filter -> App.Server.Post.fetchPostsByContext 0 filter context)

        ExcludePostsInCotonomaOptionCheck check ->
            { filter | excludePostsInCotonoma = check }
                |> withCmd
                    (\filter ->
                        if App.Types.Context.atHome context then
                            App.Server.Post.fetchPostsByContext 0 filter context
                        else
                            Cmd.none
                    )


view : Context -> Filter -> Html AppMsg.Msg
view context filter =
    Modal.view
        "timeline-filter-modal"
        (Just (modalConfig context filter))


modalConfig : Context -> Filter -> Modal.Config AppMsg.Msg
modalConfig context filter =
    { closeMessage = CloseModal
    , title = text "Timeline Filter"
    , content =
        div []
            [ excludePinnedGraphOption context filter
            , excludePostsInCotonomaOption context filter
            ]
    , buttons = []
    }


excludePinnedGraphOption : Context -> Filter -> Html AppMsg.Msg
excludePinnedGraphOption context filter =
    div [ class "filter-option pretty p-default p-curve p-smooth" ]
        [ input
            [ type_ "checkbox"
            , class "exclude-pinned-graph"
            , checked filter.excludePinnedGraph
            , onCheck (AppMsg.TimelineFilterModalMsg << ExcludePinnedGraphOptionCheck)
            ]
            []
        , div [ class "state" ]
            [ label []
                [ span []
                    [ text "Hide cotos connected from the pinned cotos" ]
                ]
            ]
        ]


excludePostsInCotonomaOption : Context -> Filter -> Html AppMsg.Msg
excludePostsInCotonomaOption context filter =
    div [ class "filter-option pretty p-default p-curve p-smooth" ]
        [ input
            [ type_ "checkbox"
            , class "exclude-posts-in-cotonoma"
            , checked filter.excludePostsInCotonoma
            , onCheck (AppMsg.TimelineFilterModalMsg << ExcludePostsInCotonomaOptionCheck)
            ]
            []
        , div [ class "state" ]
            [ label []
                [ span []
                    [ text "Hide cotos posted in a cotonoma (enabled only in "
                    , span [ class "my-home" ]
                        [ materialIcon "home" Nothing
                        , text "My Home"
                        ]
                    , text ")"
                    ]
                ]
            ]
        ]
