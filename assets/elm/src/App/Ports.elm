port module App.Ports exposing (renderCotoGraph, destroyGraph)

import Dict
import Set exposing (Set)
import App.Types.Graph exposing (Graph)
import App.Types.Coto exposing (Coto, CotoId, Cotonoma)
import App.Views.Coto


port renderGraph :
    { rootNodeId : String, nodes : List Node, edges : List Edge }
    -> Cmd msg


port destroyGraph : () -> Cmd msg


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


collectReachableCotoIds : Set CotoId -> Graph -> Set CotoId -> Set CotoId
collectReachableCotoIds sourceIds graph collectedIds =
    let
        unexploredSourceIds =
            Set.diff sourceIds collectedIds

        nextCotoIds =
            unexploredSourceIds
                |> Set.toList
                |> List.map
                    (\cotoId ->
                        graph.connections
                            |> Dict.get cotoId
                            |> Maybe.map (List.map (\conn -> conn.end))
                            |> Maybe.withDefault []
                    )
                |> List.concat
                |> Set.fromList

        updatedCollectedIds =
            Set.union collectedIds unexploredSourceIds
    in
        if Set.isEmpty nextCotoIds then
            updatedCollectedIds
        else
            collectReachableCotoIds nextCotoIds graph updatedCollectedIds


getReachableCotosFromPinnedCotos : Graph -> List Coto
getReachableCotosFromPinnedCotos graph =
    let
        pinnedCotoIds =
            graph.rootConnections
                |> List.map (\conn -> conn.end)
                |> Set.fromList
    in
        collectReachableCotoIds pinnedCotoIds graph Set.empty
            |> Set.toList
            |> List.filterMap (\id -> Dict.get id graph.cotos)


renderCotoGraph : Maybe Cotonoma -> Graph -> Cmd msg
renderCotoGraph maybeCotonoma graph =
    let
        root =
            maybeCotonoma
                |> Maybe.map
                    (\cotonoma ->
                        [ { id = cotonoma.cotoId
                          , name = cotonoma.name
                          , asCotonoma = True
                          , imageUrl =
                                cotonoma.owner
                                    |> Maybe.map (\owner -> owner.avatarUrl)
                          }
                        ]
                    )
                |> Maybe.withDefault
                    [ { id = "home"
                      , name = ""
                      , asCotonoma = False
                      , imageUrl = Nothing
                      }
                    ]

        rootId =
            maybeCotonoma
                |> Maybe.map (\cotonoma -> cotonoma.cotoId)
                |> Maybe.withDefault "home"

        nodes =
            graph
                |> getReachableCotosFromPinnedCotos
                |> List.map cotoToNode

        nodeIds =
            nodes
                |> List.map (\node -> node.id)
                |> Set.fromList

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
                            |> List.filterMap
                                (\conn ->
                                    if Set.member cotoId nodeIds && Set.member conn.end nodeIds then
                                        Just
                                            { source = cotoId
                                            , target = conn.end
                                            }
                                    else
                                        Nothing
                                )
                    )
                |> List.concat
    in
        renderGraph
            { rootNodeId = rootId
            , nodes = root ++ nodes
            , edges = rootEdges ++ edges
            }
