module App.Server.Graph exposing (..)

import Http
import Task exposing (Task, andThen)
import Json.Decode as Decode
import Json.Encode as Encode
import Util.HttpUtil exposing (ClientId, httpPut, httpDelete)
import App.Messages exposing (Msg(..))
import App.Types.Graph exposing (Direction, Connection, Graph)
import App.Types.Coto exposing (Coto, CotoId, Cotonoma, CotonomaKey)
import App.Server.Coto


decodeConnection : Decode.Decoder Connection
decodeConnection =
    Decode.map3 App.Types.Graph.initConnection
        (Decode.field "created_by" Decode.string)
        (Decode.maybe (Decode.field "start" Decode.string))
        (Decode.field "end" Decode.string)


decodeCotonomaKeyField : Decode.Decoder (Maybe String)
decodeCotonomaKeyField =
    Decode.maybe (Decode.field "cotonoma_key" Decode.string)


decodeGraph : Decode.Decoder Graph
decodeGraph =
    Decode.map3 App.Types.Graph.initGraph
        (Decode.field "cotos" (Decode.dict App.Server.Coto.decodeCoto))
        (Decode.field "root_connections" (Decode.list decodeConnection))
        (Decode.field "connections" (Decode.dict <| Decode.list decodeConnection))


fetchGraph : Maybe CotonomaKey -> Cmd Msg
fetchGraph maybeCotonomaKey =
    let
        url =
            case maybeCotonomaKey of
                Nothing ->
                    "/api/graph"

                Just cotonomaKey ->
                    "/api/graph/" ++ cotonomaKey
    in
        Http.send GraphFetched (Http.get url decodeGraph)


fetchSubgraph : CotonomaKey -> Cmd Msg
fetchSubgraph cotonomaKey =
    Http.send
        SubgraphFetched
        (Http.get ("/api/graph/subgraph/" ++ cotonomaKey) decodeGraph)


fetchSubgraphIfCotonoma : Graph -> CotoId -> Cmd Msg
fetchSubgraphIfCotonoma graph cotoId =
    graph
        |> App.Types.Graph.getCoto cotoId
        |> Maybe.andThen (\coto -> coto.asCotonoma)
        |> Maybe.map (\cotonoma -> cotonoma.key)
        |> Maybe.map fetchSubgraph
        |> Maybe.withDefault Cmd.none


pinUrl : Maybe CotonomaKey -> String
pinUrl maybeCotonomaKey =
    case maybeCotonomaKey of
        Nothing ->
            "/api/graph/pin"

        Just cotonomaKey ->
            "/api/graph/" ++ cotonomaKey ++ "/pin"


cotoIdsAsJsonBody : String -> List CotoId -> Http.Body
cotoIdsAsJsonBody key cotoIds =
    Http.jsonBody <|
        Encode.object
            [ ( key
              , Encode.list (cotoIds |> List.map (\id -> Encode.string id))
              )
            ]


pinCotos : ClientId -> Maybe CotonomaKey -> List CotoId -> Cmd Msg
pinCotos clientId maybeCotonomaKey cotoIds =
    let
        url =
            pinUrl maybeCotonomaKey

        body =
            cotoIdsAsJsonBody "coto_ids" cotoIds
    in
        Http.send CotoPinned (httpPut url clientId body (Decode.succeed "done"))


unpinCoto : ClientId -> Maybe CotonomaKey -> CotoId -> Cmd Msg
unpinCoto clientId maybeCotonomaKey cotoId =
    let
        url =
            (pinUrl maybeCotonomaKey) ++ "/" ++ cotoId
    in
        Http.send CotoUnpinned (httpDelete url clientId)


connectUrl : Maybe CotonomaKey -> CotoId -> String
connectUrl maybeCotonomaKey startId =
    maybeCotonomaKey
        |> Maybe.map
            (\cotonomaKey ->
                "/api/graph/" ++ cotonomaKey ++ "/connection/" ++ startId
            )
        |> Maybe.withDefault ("/api/graph/connection/" ++ startId)


connectTask : ClientId -> Maybe CotonomaKey -> Direction -> List CotoId -> CotoId -> Task Http.Error (List String)
connectTask clientId maybeCotonomaKey direction objects subject =
    let
        requests =
            case direction of
                App.Types.Graph.Outbound ->
                    [ httpPut
                        (connectUrl maybeCotonomaKey subject)
                        clientId
                        (cotoIdsAsJsonBody "end_ids" objects)
                        (Decode.succeed "done")
                    ]

                App.Types.Graph.Inbound ->
                    List.map
                        (\startId ->
                            httpPut
                                (connectUrl maybeCotonomaKey startId)
                                clientId
                                (cotoIdsAsJsonBody "end_ids" [ subject ])
                                (Decode.succeed "done")
                        )
                        objects
    in
        requests |> List.map Http.toTask |> Task.sequence


connect : ClientId -> Maybe CotonomaKey -> Direction -> List CotoId -> CotoId -> Cmd Msg
connect clientId maybeCotonomaKey direction objects subject =
    connectTask clientId maybeCotonomaKey direction objects subject
        |> Task.attempt Connected


disconnect : ClientId -> Maybe CotonomaKey -> CotoId -> CotoId -> Cmd Msg
disconnect clientId maybeCotonomaKey startId endId =
    let
        url =
            (connectUrl maybeCotonomaKey startId) ++ "/" ++ endId
    in
        Http.send ConnectionDeleted (httpDelete url clientId)


reorder : ClientId -> Maybe CotonomaKey -> Maybe CotoId -> List CotoId -> Cmd Msg
reorder clientId maybeCotonomaKey maybeStartId endIds =
    let
        url =
            maybeStartId
                |> Maybe.map
                    (\startId ->
                        "/api/graph/connection/" ++ startId ++ "/reorder"
                    )
                |> Maybe.withDefault
                    (maybeCotonomaKey
                        |> Maybe.map
                            (\cotonomaKey ->
                                "/api/graph/" ++ cotonomaKey ++ "/reorder"
                            )
                        |> Maybe.withDefault "/api/graph/reorder"
                    )
    in
        Http.send ConnectionsReordered <|
            httpPut
                url
                clientId
                (cotoIdsAsJsonBody "end_ids" endIds)
                (Decode.succeed "done")
