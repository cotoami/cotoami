module Components.Pinned.View exposing (..)

import Dict
import Html exposing (..)
import Html.Keyed
import Html.Attributes exposing (..)
import Markdown
import Utils exposing (onClickWithoutPropagation)
import App.Types exposing (Coto, CotoId, Cotonoma, CotoSelection)
import App.Graph exposing (..)
import App.Markdown exposing (markdownOptions, markdownElements)
import Components.Pinned.Messages exposing (..)
import Components.Coto


view : Dict.Dict CotoId Traversal -> CotoSelection -> Maybe Cotonoma -> Graph -> Html Msg
view traversals selection maybeCotonoma graph =
    div [ id "pinned-cotos" ]
        [ div [ class "column-header" ] 
            [ i [ class "pinned fa fa-thumb-tack", (attribute "aria-hidden" "true") ] []
            ]
        , div [ class "column-body" ]
            [ rootConnections selection maybeCotonoma graph ]
        ]


rootConnections : CotoSelection -> Maybe Cotonoma -> Graph -> Html Msg
rootConnections selection maybeCotonoma graph =
    connectionsDiv
        Nothing
        "root-connections" 
        graph.rootConnections 
        selection 
        maybeCotonoma 
        graph


connectionsDiv : Maybe ( Traversal, Int ) -> String -> List Connection -> CotoSelection -> Maybe Cotonoma -> Graph -> Html Msg
connectionsDiv maybeTraversalStep divClass connections selection maybeCotonoma graph =
    Html.Keyed.node
        "div"
        [ class divClass ]
        (List.map 
            (\conn ->
                let
                    maybeCoto = Dict.get conn.end graph.cotos
                in
                    ( conn.key
                    , case maybeCoto of
                        Nothing -> 
                            div [ class "outbound-conn missing" ] [ text "Missing" ]
                        Just coto ->
                            div 
                                [ classList 
                                    [ ( "outbound-conn", True )
                                    , ( "traversed"
                                      , case maybeTraversalStep of
                                          Nothing -> False
                                          Just ( traversal, index ) -> 
                                              traversed index coto.id traversal
                                      )
                                    ]
                                ]
                                [ cotoDiv maybeTraversalStep selection maybeCotonoma graph coto
                                ]
                            
                    )
            ) 
            (List.reverse connections)
        )
    
  
cotoDiv : Maybe ( Traversal, Int ) -> CotoSelection -> Maybe Cotonoma -> Graph -> Coto -> Html Msg
cotoDiv maybeTraversalStep selection maybeCotonoma graph coto =
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
            , markdown coto.content
            , case maybeTraversalStep of
                Nothing ->
                    Components.Coto.openTraversalButtonDiv OpenTraversal (Just coto.id) graph 
                Just ( traversal, index ) -> 
                    Components.Coto.traverseButtonDiv TraverseClick index coto.id traversal graph
            ]
        ]
    

markdown : String -> Html Msg
markdown content =
    div [ class "content" ]
        <| Markdown.customHtml 
            markdownOptions
            markdownElements
            content
