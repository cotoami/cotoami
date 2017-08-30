module App.Server.Graph exposing (..)

import Http
import Task exposing (Task, andThen)
import Json.Decode as Decode
import Json.Encode as Encode
import Utils exposing (httpPut, httpDelete)
import App.Messages exposing (Msg(..))
import App.Types.Graph exposing (Connection, initConnection, Graph, getCoto)
import App.Types.Coto exposing (Coto, CotoId, initCoto, Cotonoma, CotonomaKey)
import App.Server.Amishi exposing (decodeAmishi)
import App.Server.Cotonoma exposing (decodeCotonoma)


decodeConnection : Decode.Decoder Connection
decodeConnection =
    Decode.map2 initConnection
        (Decode.maybe (Decode.field "start" Decode.string))
        (Decode.field "end" Decode.string)


decodeCoto : Decode.Decoder Coto
decodeCoto =
    Decode.map5 initCoto
        (Decode.field "uuid" Decode.string)
        (Decode.field "content" Decode.string)
        (Decode.maybe (Decode.field "amishi" decodeAmishi))
        (Decode.maybe (Decode.field "posted_in" decodeCotonoma))
        (Decode.maybe (Decode.field "cotonoma_key" Decode.string))


decodeGraph : Decode.Decoder Graph
decodeGraph =
    Decode.map3 Graph
        (Decode.field "cotos" (Decode.dict decodeCoto))
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
    case getCoto cotoId graph of
        Nothing ->
            Cmd.none

        Just coto ->
            case coto.cotonomaKey of
                Nothing ->
                    Cmd.none

                Just cotonomaKey ->
                    fetchSubgraph cotonomaKey


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


pinCotos : Maybe CotonomaKey -> List CotoId -> Cmd Msg
pinCotos maybeCotonomaKey cotoIds =
    let
        url = pinUrl maybeCotonomaKey
        body = cotoIdsAsJsonBody "coto_ids" cotoIds
    in
        Http.send CotoPinned (httpPut url body (Decode.succeed "done"))


unpinCoto : Maybe CotonomaKey -> CotoId -> Cmd Msg
unpinCoto maybeCotonomaKey cotoId =
    let
        url = (pinUrl maybeCotonomaKey) ++ "/" ++ cotoId
    in
        Http.send CotoUnpinned (httpDelete url)


connectUrl : Maybe CotonomaKey -> CotoId -> String
connectUrl maybeCotonomaKey startId =
    case maybeCotonomaKey of
        Nothing ->
            "/api/graph/connection/" ++ startId

        Just cotonomaKey ->
            "/api/graph/" ++ cotonomaKey ++ "/connection/" ++ startId


connectTask : Maybe CotonomaKey -> Bool -> List CotoId -> CotoId -> Task Http.Error (List String)
connectTask maybeCotonomaKey outbound objects subject =
    let
        requests =
            if outbound then
                [ httpPut
                    (connectUrl maybeCotonomaKey subject)
                    (cotoIdsAsJsonBody "end_ids" objects)
                    (Decode.succeed "done")
                ]
            else
                List.map
                    (\startId ->
                        httpPut
                            (connectUrl maybeCotonomaKey startId)
                            (cotoIdsAsJsonBody "end_ids" [ subject ])
                            (Decode.succeed "done")
                    )
                    objects
    in
        requests |> List.map Http.toTask |> Task.sequence


connect : Maybe CotonomaKey -> Bool ->List CotoId -> CotoId -> Cmd Msg
connect maybeCotonomaKey outbound objects subject =
    connectTask maybeCotonomaKey outbound objects subject
        |> Task.attempt Connected


disconnect : Maybe CotonomaKey -> CotoId -> CotoId -> Cmd Msg
disconnect maybeCotonomaKey startId endId =
    let
        url = (connectUrl maybeCotonomaKey startId) ++ "/" ++ endId
    in
        Http.send ConnectionDeleted (httpDelete url)
