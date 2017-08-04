module App.Server.Graph exposing (..)

import Http
import Json.Decode as Decode
import Json.Encode as Encode
import Utils exposing (httpPut, httpDelete)
import App.Messages exposing (Msg(..))
import App.Types.Graph exposing (Connection, initConnection, Graph, getCoto)
import App.Types.Coto exposing (Coto, CotoId, initCoto, CotonomaKey)
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
                Nothing -> "/api/graph"
                Just cotonomaKey -> "/api/graph/" ++ cotonomaKey
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
        Nothing -> Cmd.none
        Just coto ->
            case coto.cotonomaKey of
                Nothing -> Cmd.none
                Just cotonomaKey -> fetchSubgraph cotonomaKey


pinUrl : Maybe CotonomaKey -> String
pinUrl maybeCotonomaKey =
    case maybeCotonomaKey of
        Nothing -> "/api/graph/pin"
        Just cotonomaKey -> "/api/graph/" ++ cotonomaKey ++ "/pin"


pinCotos : (Result Http.Error String -> msg) -> Maybe CotonomaKey -> List CotoId -> Cmd msg
pinCotos tag maybeCotonomaKey cotoIds =
    let
        url = pinUrl maybeCotonomaKey
        body =
            Http.jsonBody
                <| Encode.object
                    [ ( "coto_ids"
                      , Encode.list (cotoIds |> List.map (\id -> Encode.string id))
                      )
                    ]
    in
        Http.send tag (httpPut url body (Decode.succeed "done"))


unpinCoto : (Result Http.Error String -> msg) -> Maybe CotonomaKey -> CotoId -> Cmd msg
unpinCoto tag maybeCotonomaKey cotoId =
    let
        url = (pinUrl maybeCotonomaKey) ++ "/" ++ cotoId
    in
        Http.send tag (httpDelete url)
