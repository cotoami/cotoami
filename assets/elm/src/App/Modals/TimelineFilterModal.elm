module App.Modals.TimelineFilterModal exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Util.Modal as Modal
import App.Messages exposing (Msg(CloseModal))
import App.Types.Context exposing (Context)
import App.Types.Timeline exposing (Filter)


view : Context -> Filter -> Html Msg
view context filter =
    Modal.view
        "timeline-filter-modal"
        (Just (modalConfig context filter))


modalConfig : Context -> Filter -> Modal.Config Msg
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


excludePinnedGraphOption : Context -> Filter -> Html Msg
excludePinnedGraphOption context filter =
    div [ class "filter-option pretty p-default p-curve p-smooth" ]
        [ input
            [ type_ "checkbox"
            , class "exclude-pinned-graph"
            , checked filter.excludePinnedGraph
            ]
            []
        , div [ class "state" ]
            [ label []
                [ span []
                    [ text "Hide cotos connected from the pinned cotos" ]
                ]
            ]
        ]


excludePostsInCotonomaOption : Context -> Filter -> Html Msg
excludePostsInCotonomaOption context filter =
    div [ class "filter-option pretty p-default p-curve p-smooth" ]
        [ input
            [ type_ "checkbox"
            , class "exclude-posts-in-cotonoma"
            , checked filter.excludePostsInCotonoma
            ]
            []
        , div [ class "state" ]
            [ label []
                [ span []
                    [ text "Hide cotos posted in a cotonoma (enabled only in "
                    , span [ class "my-home" ] [ text "My Home" ]
                    , text ")"
                    ]
                ]
            ]
        ]
