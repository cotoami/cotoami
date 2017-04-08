module Components.Connections.View exposing (..)

import Dict
import Html exposing (..)
import Html.Keyed
import Html.Attributes exposing (..)
import Markdown
import Utils exposing (onClickWithoutPropagation)
import App.Types exposing (Coto, CotoSelection)
import App.Graph exposing (..)
import App.Markdown exposing (markdownOptions, markdownElements)
import Components.Connections.Messages exposing (..)


view : CotoSelection -> Graph -> Html Msg
view selection graph =
    Html.Keyed.node
        "div"
        [ id "connections" ]
        (
          ( "column-roots"
          , div [ id "column-roots", class "connections-column" ]
              [ div [ class "column-header" ] 
                  [ i [ class "pinned fa fa-thumb-tack", (attribute "aria-hidden" "true") ] []
                  ]
              , rootConnections selection graph 
              ]
          ) ::
              List.map
                  (\traversal ->
                      let
                          coto = Tuple.first traversal
                          connections = Tuple.second traversal
                      in
                          ( "column-traversal-" ++ toString coto.id
                          , div 
                              [ class "column-traversal connections-column" ]
                              [ traversalCoto connections coto selection graph ]
                          )  
                  ) 
                  (graph |> getSecondConnections |> List.reverse)
        )


rootConnections : CotoSelection -> Graph -> Html Msg
rootConnections selection graph =
    connectionsDiv "root-connections" graph.rootConnections selection graph


traversalCoto : List Connection -> Coto -> CotoSelection -> Graph -> Html Msg
traversalCoto connections coto selection graph =
    div (cotoDivAttrs selection coto)
        [ markdown coto.content
        , div [ class "main-sub-border" ] []
        , connectionsDiv "sub-cotos" connections selection graph
        ]
  

connectionsDiv : String -> List Connection -> CotoSelection -> Graph -> Html Msg
connectionsDiv divClass connections selection graph =
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
                        Nothing -> div [ class "coto missing" ] [ text "Missing" ]
                        Just coto -> cotoDiv selection coto
                    )
            ) 
            (List.reverse connections)
        )


cotoDivAttrs : CotoSelection -> Coto -> List (Attribute Msg)
cotoDivAttrs selection coto =
    [ classList 
        [ ( "coto", True )
        , ( "selectable", True )
        , ( "active", List.member coto.id selection )
        ]
    , onClickWithoutPropagation (CotoClick coto.id)
    ] 
    
  
cotoDiv : CotoSelection -> Coto -> Html Msg
cotoDiv selection coto =
    div (cotoDivAttrs selection coto) [ markdown coto.content ]
    

markdown : String -> Html Msg
markdown content =
    div [ class "content" ]
        <| Markdown.customHtml 
            markdownOptions
            markdownElements
            content
