port module App.Ports exposing (renderCotoGraph)

import Dict
import App.Types.Graph exposing (Graph)
import App.Types.Coto exposing (Coto, Cotonoma)
import App.Views.Coto


port renderGraph :
    { rootNodeId : String, nodes : List Node, edges : List Edge }
    -> Cmd msg


type alias Node =
    { id : String
    , name : String
    , asCotonoma : Bool
    , imageUrl : Maybe String
    }


type alias Edge =
    { source : String
    , target : String
    }


cotoToNode : Coto -> Node
cotoToNode coto =
    { id = coto.id
    , name = App.Views.Coto.abbreviate coto
    , asCotonoma = coto.asCotonoma
    , imageUrl = coto.amishi |> Maybe.map (\amishi -> amishi.avatarUrl)
    }


renderCotoGraph : Maybe Cotonoma -> Graph -> Cmd msg
renderCotoGraph maybeCotonoma graph =
    let
        homeNode =
            maybeCotonoma
                |> Maybe.map (\_ -> [])
                |> Maybe.withDefault
                    [ { id = "home"
                      , name = ""
                      , asCotonoma = False
                      , imageUrl = Nothing
                      }
                    ]

        nodes =
            graph.cotos
                |> Dict.values
                |> List.map cotoToNode

        rootId =
            maybeCotonoma
                |> Maybe.map (\cotonoma -> cotonoma.cotoId)
                |> Maybe.withDefault "home"

        rootEdges =
            graph.rootConnections
                |> List.map
                    (\conn ->
                        { source = rootId
                        , target = conn.end
                        }
                    )

        edges =
            graph.connections
                |> Dict.toList
                |> List.map
                    (\( cotoId, conns ) ->
                        conns
                            |> List.map
                                (\conn ->
                                    { source = cotoId
                                    , target = conn.end
                                    }
                                )
                    )
                |> List.concat
    in
        renderGraph
            { rootNodeId = rootId
            , nodes = homeNode ++ nodes
            , edges = rootEdges ++ edges
            }
