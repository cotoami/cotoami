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
import App.Ports.Storage


update : Context -> TimelineFilterModalMsg.Msg -> Filter -> ( Filter, Cmd AppMsg.Msg )
update context msg filter =
    case msg of
        ExcludePinnedGraphOptionCheck check ->
            { filter | excludePinnedGraph = check }
                |> withCmd (cmdOnFilterUpdate_ context)

        ExcludePostsInCotonomaOptionCheck check ->
            { filter | excludePostsInCotonoma = check }
                |> withCmd (cmdOnFilterUpdate_ context)


cmdOnFilterUpdate_ : Context -> Filter -> Cmd AppMsg.Msg
cmdOnFilterUpdate_ context filter =
    Cmd.batch
        [ App.Server.Post.fetchPostsByContext 0 filter context
        , App.Ports.Storage.setItem
            ( "timeline.filter"
            , App.Types.Timeline.encodeFilter filter
            )
        ]


view : Context -> Filter -> Html AppMsg.Msg
view context filter =
    Modal.view
        "timeline-filter-modal"
        (Just (modalConfig_ context filter))


modalConfig_ : Context -> Filter -> Modal.Config AppMsg.Msg
modalConfig_ context filter =
    { closeMessage = CloseModal
    , title = text "Timeline Filter"
    , content =
        div []
            [ excludePinnedGraphOption_ context filter
            , if App.Types.Context.atHome context then
                excludePostsInCotonomaOption_ context filter
              else
                Util.HtmlUtil.none
            ]
    , buttons = []
    }


excludePinnedGraphOption_ : Context -> Filter -> Html AppMsg.Msg
excludePinnedGraphOption_ context filter =
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
                    [ text "Hide cotos incorporated in the pinned documents" ]
                ]
            ]
        ]


excludePostsInCotonomaOption_ : Context -> Filter -> Html AppMsg.Msg
excludePostsInCotonomaOption_ context filter =
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
                    [ text "Hide cotos posted in a cotonoma other than "
                    , span [ class "my-home" ]
                        [ materialIcon "home" Nothing
                        , text "My Home"
                        ]
                    ]
                ]
            ]
        ]
