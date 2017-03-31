module Components.Connections.View exposing (..)

import Dict
import Html exposing (..)
import Html.Keyed
import Html.Attributes exposing (..)
import Markdown
import App.Types exposing (Coto)
import App.Markdown exposing (markdownOptions, markdownElements)
import Components.Connections.Model exposing (..)
import Components.Connections.Messages exposing (..)


view : Model -> Html Msg
view model =
    Html.Keyed.node
        "div"
        [ id "connections" ]
        (
          ( "column-roots"
          , div [ id "column-roots", class "connections-column" ]
              [ rootConnections model ]
          ) ::
              List.map
                  (\traversal ->
                      let
                          coto = Tuple.first traversal
                          connections = Tuple.second traversal
                      in
                          ( "column-traversal-" ++ toString coto.id
                          , div [ class "column-traversal connections-column" ]
                              [ traversalCoto connections coto model ]
                          )  
                  ) 
                  (getSecondConnections model)
        )


rootConnections : Model -> Html Msg
rootConnections model =
    connectionsDiv "root-connections" model.rootConnections model


traversalCoto : List Connection -> Coto -> Model -> Html Msg
traversalCoto connections coto model =
    div [ class "coto" ]
        [ markdown coto.content
        , connectionsDiv "sub-cotos" connections model
        ]
  

connectionsDiv : String -> List Connection -> Model -> Html Msg
connectionsDiv divClass connections model =
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
                        Just coto -> cotoDiv coto
                    )
            ) 
            connections
        )
        
  
cotoDiv : Coto -> Html Msg
cotoDiv coto =
    div [ class "coto" ] [ markdown coto.content ]
    

markdown : String -> Html Msg
markdown content =
    div [ class "content" ]
        <| Markdown.customHtml 
            markdownOptions
            markdownElements
            content
