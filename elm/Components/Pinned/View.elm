module Components.Pinned.View exposing (..)

import Dict
import Html exposing (..)
import Html.Keyed
import Html.Attributes exposing (..)
import Utils exposing (onClickWithoutPropagation)
import App.Types exposing (Coto, CotoId, Cotonoma, CotoSelection)
import App.Graph exposing (..)
import App.Markdown
import App.Messages exposing (..)
import Components.Coto


view : CotoSelection -> Maybe Cotonoma -> Graph -> Html Msg
view selection maybeCotonoma graph =
    div [ id "pinned-cotos" ]
        [ div 
            [ class "column-header" ] 
            [ i [ class "pinned fa fa-thumb-tack", (attribute "aria-hidden" "true") ] []
            ]
        , div 
            [ class "column-body" ]
            [ pinnedCotos selection maybeCotonoma graph ]
        ]


pinnedCotos : CotoSelection -> Maybe Cotonoma -> Graph -> Html Msg
pinnedCotos selection maybeCotonoma graph =
    connectionsDiv
        "root-connections" 
        graph.rootConnections 
        selection 
        maybeCotonoma 
        graph


connectionsDiv : String -> List Connection -> CotoSelection -> Maybe Cotonoma -> Graph -> Html Msg
connectionsDiv divClass connections selection maybeCotonoma graph =
    Html.Keyed.node
        "div"
        [ class divClass ]
        (List.filterMap 
            (\conn ->
                case Dict.get conn.end graph.cotos of
                    Nothing -> Nothing  -- Missing the end node
                    Just coto -> Just 
                        ( conn.key
                        , connectionDiv selection maybeCotonoma graph coto
                        ) 
            ) 
            (List.reverse connections)
        )
        
        
connectionDiv : CotoSelection -> Maybe Cotonoma -> Graph -> Coto -> Html Msg
connectionDiv selection maybeCotonoma graph coto =
    div [ class "outbound-conn" ]
        [ cotoDiv selection maybeCotonoma graph coto ]
        
  
cotoDiv : CotoSelection -> Maybe Cotonoma -> Graph -> Coto -> Html Msg
cotoDiv selection maybeCotonoma graph coto =
    div 
        [ classList 
            [ ( "coto", True )
            , ( "selectable", True )
            , ( "active", List.member coto.id selection )
            ]
        , onClickWithoutPropagation (CotoClick coto.id)
        ]
        [ div 
            [ class "coto-inner" ]
            [ Components.Coto.headerDiv CotonomaClick maybeCotonoma graph coto
            , App.Markdown.markdown coto.content
            , Components.Coto.openTraversalButtonDiv OpenTraversal (Just coto.id) graph 
            ]
        ]
