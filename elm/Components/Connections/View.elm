module Components.Connections.View exposing (..)

import Dict
import Html exposing (..)
import Html.Keyed
import Html.Attributes exposing (..)
import Markdown
import Utils exposing (onClickWithoutPropagation)
import App.Types exposing (Coto, Cotonoma, CotoSelection)
import App.Graph exposing (..)
import App.Markdown exposing (markdownOptions, markdownElements)
import Components.Connections.Messages exposing (..)
import Components.Coto


view : CotoSelection -> Maybe Cotonoma -> Graph -> Html Msg
view selection maybeCotonoma graph =
    Html.Keyed.node
        "div"
        [ id "connections" ]
        (
          ( "column-roots"
          , div [ id "column-roots", class "connections-column" ]
              [ div [ class "column-header" ] 
                  [ i [ class "pinned fa fa-thumb-tack", (attribute "aria-hidden" "true") ] []
                  ]
              , rootConnections selection maybeCotonoma graph 
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
                              [ traversalCoto connections coto selection maybeCotonoma graph ]
                          )  
                  ) 
                  (graph |> getSecondConnections |> List.reverse)
        )


rootConnections : CotoSelection -> Maybe Cotonoma -> Graph -> Html Msg
rootConnections selection maybeCotonoma graph =
    connectionsDiv 
        "root-connections" 
        graph.rootConnections 
        selection 
        maybeCotonoma 
        graph


traversalCoto : List Connection -> Coto -> CotoSelection -> Maybe Cotonoma -> Graph -> Html Msg
traversalCoto connections coto selection maybeCotonoma graph =
    div (cotoDivAttrs selection coto)
        [ Components.Coto.headerDiv CotonomaClick maybeCotonoma graph coto
        , markdown coto.content
        , div [ class "main-sub-border" ] []
        , connectionsDiv "sub-cotos" connections selection maybeCotonoma graph
        ]
  

connectionsDiv : String -> List Connection -> CotoSelection -> Maybe Cotonoma -> Graph -> Html Msg
connectionsDiv divClass connections selection maybeCotonoma graph =
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
                        Just coto -> cotoDiv selection maybeCotonoma graph coto
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
    
  
cotoDiv : CotoSelection -> Maybe Cotonoma -> Graph -> Coto -> Html Msg
cotoDiv selection maybeCotonoma graph coto =
    div (cotoDivAttrs selection coto) 
        [ Components.Coto.headerDiv CotonomaClick maybeCotonoma graph coto
        , markdown coto.content
        , Components.Coto.subCotosButtonDiv graph (Just coto.id)
        ]
    

markdown : String -> Html Msg
markdown content =
    div [ class "content" ]
        <| Markdown.customHtml 
            markdownOptions
            markdownElements
            content
