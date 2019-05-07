module App.Channels exposing
    ( Payload
    , PresenceEntry
    , convertPresenceEntriesToConnCounts
    , cotoChannels
    , cotonomaChannels
    , decodePayload
    , decodePresenceDiff
    , decodePresenceEntries
    , decodePresenceState
    , globalChannel
    , timelineChannel
    )

import App.Messages exposing (..)
import App.Server.Amishi
import App.Types.Amishi exposing (Amishi, Presences)
import App.Types.Coto exposing (CotoId, CotonomaKey)
import Dict
import Json.Decode as Decode
import Json.Encode exposing (Value)
import Phoenix.Channel as Channel exposing (Channel)
import Set exposing (Set)
import Utils.HttpUtil exposing (ClientId(ClientId))


globalChannel : Channel Msg
globalChannel =
    Channel.init "global"


cotonomaChannels : Set CotonomaKey -> List (Channel Msg)
cotonomaChannels keys =
    keys
        |> Set.toList
        |> List.map
            (\key ->
                Channel.init ("cotonomas:" ++ key)
                    |> Channel.on "update" CotonomaUpdatePushed
            )


timelineChannel : CotonomaKey -> Channel Msg
timelineChannel key =
    Channel.init ("timelines:" ++ key)
        |> Channel.on "presence_state" CotonomaPresenceState
        |> Channel.on "presence_diff" CotonomaPresenceDiff
        |> Channel.on "post" PostPushed


cotoChannels : Set CotoId -> List (Channel Msg)
cotoChannels cotoIds =
    cotoIds
        |> Set.toList
        |> List.map
            (\cotoId ->
                Channel.init ("cotos:" ++ cotoId)
                    |> Channel.on "delete" DeletePushed
                    |> Channel.on "update" CotoUpdatePushed
                    |> Channel.on "cotonomatize" CotonomatizePushed
                    |> Channel.on "connect" ConnectPushed
                    |> Channel.on "disconnect" DisconnectPushed
                    |> Channel.on "connection_update" ConnectionUpdatePushed
                    |> Channel.on "reorder" ReorderPushed
            )


type alias Payload body =
    { clientId : ClientId
    , amishi : Amishi
    , body : body
    }


decodePayload : Decode.Decoder body -> Decode.Decoder (Payload body)
decodePayload bodyDecoder =
    Decode.map3 Payload
        (Decode.field "clientId" (Decode.map ClientId Decode.string))
        (Decode.field "amishi" App.Server.Amishi.decodeAmishi)
        (Decode.field "body" bodyDecoder)



-- https://hexdocs.pm/phoenix/Phoenix.Presence.html
-- {<amishi-uuid>: {metas: [{phx_ref: "5OaVq4AmYbU=", online_at: 1490350876053}]}}


type alias PresenceEntry =
    ( String, List ( String, List ( String, Int ) ) )


decodePresenceEntries : Decode.Decoder (List PresenceEntry)
decodePresenceEntries =
    Decode.keyValuePairs
    -- Amishi ID
    <|
        Decode.keyValuePairs
        -- "metas"
        <|
            Decode.list <|
                Decode.map2 (,)
                    (Decode.field "phx_ref" Decode.string)
                    (Decode.field "online_at" Decode.int)


convertPresenceEntriesToConnCounts : List PresenceEntry -> Presences
convertPresenceEntriesToConnCounts entries =
    List.map
        (\entry ->
            ( Tuple.first entry
            , Tuple.second entry |> List.length
            )
        )
        entries
        |> Dict.fromList


decodePresenceState : Value -> Presences
decodePresenceState payload =
    case Decode.decodeValue decodePresenceEntries payload of
        Ok decodedPayload ->
            convertPresenceEntriesToConnCounts decodedPayload

        Err err ->
            Dict.empty



-- https://hexdocs.pm/phoenix/Phoenix.Presence.html
-- {leaves: {3: {metas: [{phx_ref: "7h9YpxuqCmM=", online_at: 1490350421829}]}}, joins: {}}


decodePresenceDiff : Value -> ( Presences, Presences )
decodePresenceDiff payload =
    Decode.map2 (,)
        (Decode.field "joins" decodePresenceEntries)
        (Decode.field "leaves" decodePresenceEntries)
        |> (\decoder ->
                case Decode.decodeValue decoder payload of
                    Ok decodedPayload ->
                        ( decodedPayload |> Tuple.first |> convertPresenceEntriesToConnCounts
                        , decodedPayload |> Tuple.second |> convertPresenceEntriesToConnCounts
                        )

                    Err err ->
                        ( Dict.empty, Dict.empty )
           )
