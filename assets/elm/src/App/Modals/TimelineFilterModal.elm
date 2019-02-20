module App.Modals.TimelineFilterModal exposing (update, view)

import App.I18n.Keys as I18nKeys
import App.LocalConfig
import App.Messages as AppMsg exposing (Msg(CloseModal))
import App.Modals.TimelineFilterModalMsg as TimelineFilterModalMsg exposing (Msg(..))
import App.Server.Post
import App.Submodels.Context exposing (Context)
import App.Types.TimelineFilter exposing (TimelineFilter)
import App.Views.Flow
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onCheck)
import Utils.HtmlUtil exposing (materialIcon)
import Utils.Modal
import Utils.UpdateUtil exposing (addCmd, withCmd, withoutCmd)


type alias UpdateModel model =
    { model
        | flowView : App.Views.Flow.Model
    }


update : Context a -> TimelineFilterModalMsg.Msg -> UpdateModel model -> ( UpdateModel model, Cmd AppMsg.Msg )
update context msg ({ flowView } as model) =
    case msg of
        ExcludePinnedGraphOptionCheck check ->
            flowView.filter
                |> (\filter -> { filter | excludePinnedGraph = check })
                |> (\filter -> App.Views.Flow.setFilter filter flowView)
                |> (\flowView -> { model | flowView = flowView })
                |> withCmd (\model -> saveUpdate context model.flowView.filter)

        ExcludePostsInCotonomaOptionCheck check ->
            flowView.filter
                |> (\filter -> { filter | excludePostsInCotonoma = check })
                |> (\filter -> App.Views.Flow.setFilter filter flowView)
                |> (\flowView -> { model | flowView = flowView })
                |> withCmd (\model -> saveUpdate context model.flowView.filter)


saveUpdate : Context a -> TimelineFilter -> Cmd AppMsg.Msg
saveUpdate context filter =
    Cmd.batch
        [ App.Server.Post.fetchPostsByContext 0 filter context
        , App.LocalConfig.saveTimelineFilter filter
        ]


view : Context a -> TimelineFilter -> Html AppMsg.Msg
view context model =
    model
        |> modalConfig context
        |> Utils.Modal.view "timeline-filter-modal"


modalConfig : Context a -> TimelineFilter -> Utils.Modal.Config AppMsg.Msg
modalConfig context filter =
    { closeMessage = CloseModal
    , title = text (context.i18nText I18nKeys.TimelineFilterModal_Title)
    , content =
        div []
            [ excludePinnedGraphOption context filter
            , if App.Submodels.Context.atHome context then
                excludePostsInCotonomaOption context filter

              else
                Utils.HtmlUtil.none
            ]
    , buttons = []
    }


excludePinnedGraphOption : Context a -> TimelineFilter -> Html AppMsg.Msg
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
                    [ text
                        (context.i18nText
                            I18nKeys.TimelineFilterModal_ExcludePinnedGraph
                        )
                    ]
                ]
            ]
        ]


excludePostsInCotonomaOption : Context a -> TimelineFilter -> Html AppMsg.Msg
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
                    [ text
                        (context.i18nText
                            I18nKeys.TimelineFilterModal_ExcludePostsInCotonoma
                        )
                    ]
                ]
            ]
        ]
