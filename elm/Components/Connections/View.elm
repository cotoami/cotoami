module Components.Connections.View exposing (..)

import Dict
import Html exposing (..)
import Html.Keyed
import Html.Attributes exposing (..)
import Markdown
import Utils exposing (onClickWithoutPropagation)
import App.Types exposing (Coto, CotoSelection)
import App.Markdown exposing (markdownOptions, markdownElements)
import Components.Connections.Model exposing (..)
import Components.Connections.Messages exposing (..)


view : CotoSelection -> Model -> Html Msg
view selection model =
    Html.Keyed.node
        "div"
        [ id "connections" ]
        (
          ( "column-roots"
          , div [ id "column-roots", class "connections-column" ]
              [ rootConnections selection model ]
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
                              [ traversalCoto connections coto selection model ]
                          )  
                  ) 
                  (model |> getSecondConnections |> List.reverse)
        )


rootConnections : CotoSelection -> Model -> Html Msg
rootConnections selection model =
    connectionsDiv "root-connections" model.rootConnections selection model


traversalCoto : List Connection -> Coto -> CotoSelection -> Model -> Html Msg
traversalCoto connections coto selection model =
    div (cotoDivAttrs selection coto)
        [ markdown coto.content
        , div [ class "main-sub-border" ] []
        , connectionsDiv "sub-cotos" connections selection model
        ]
  

connectionsDiv : String -> List Connection -> CotoSelection -> Model -> Html Msg
connectionsDiv divClass connections selection model =
    Html.Keyed.node
        "div"
        [ class divClass ]
        (List.map 
            (\conn ->
                let
                    maybeCoto = Dict.get conn.end model.cotos
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
