module Components.Traversal exposing (..)

import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import App.Types exposing (Coto, CotoId, Cotonoma, CotoSelection)
import App.Model exposing (..)
import App.Messages exposing (..)
import App.Graph exposing (..)
import App.Markdown
import Components.Coto


traversalDiv : Traversal -> List Connection -> Coto -> CotoSelection -> Maybe Cotonoma -> Graph -> Html Msg
traversalDiv traversal connections coto selection maybeCotonoma graph =
    div [ class "traversal" ]
        [ traversalStepCotoDiv ( traversal, -1 ) connections coto selection maybeCotonoma graph
        , div [ class "steps" ]
            (List.reverse traversal.steps
            |> List.indexedMap (\index step -> traversalStepDiv ( traversal, index ) step selection maybeCotonoma graph) 
            |> List.filterMap identity)
        ]
        

traversalStepDiv : ( Traversal, Int ) -> CotoId -> CotoSelection -> Maybe Cotonoma -> Graph -> Maybe (Html Msg)
traversalStepDiv traversalStep cotoId selection maybeCotonoma graph =
    case Dict.get cotoId graph.cotos of
        Nothing -> Nothing
        Just coto -> Just
            (div [ class "step" ]
                [ div [ class "arrow" ]
                    [ i [ class "material-icons" ] [ text "arrow_downward" ]
                    ]
                , traversalStepCotoDiv 
                    traversalStep
                    (case Dict.get cotoId graph.connections of
                        Nothing -> []
                        Just connections -> connections
                    )
                    coto 
                    selection 
                    maybeCotonoma 
                    graph
                ]
            )


traversalStepCotoDiv : ( Traversal, Int ) -> List Connection -> Coto -> CotoSelection -> Maybe Cotonoma -> Graph -> Html Msg
traversalStepCotoDiv traversalStep connections coto selection maybeCotonoma graph =
    div [ classList 
            [ ( "coto", True )
            , ( "selectable", True )
            , ( "active", List.member coto.id selection )
            ]
        ]
        [ Components.Coto.headerDiv CotonomaClick maybeCotonoma graph coto
        , App.Markdown.markdown coto.content
        , div [ class "main-sub-border" ] []
        , connectionsDiv (Just traversalStep) "sub-cotos" connections selection maybeCotonoma graph
        ]
