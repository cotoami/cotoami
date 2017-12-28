module App.Channels exposing (..)

import Dict
import Json.Encode exposing (Value)
import Json.Decode as Decode
import Phoenix.Channel as Channel exposing (Channel)
import Util.HttpUtil exposing (ClientId(ClientId))
import App.Types.Coto exposing (CotonomaKey)
import App.Types.Amishi exposing (Presences)
import App.Messages exposing (..)


globalChannel : Channel Msg
globalChannel =
    Channel.init ("global")
        |> Channel.on "delete"
            (\payload -> DeletePushed payload)


cotonomaChannel : CotonomaKey -> Channel Msg
cotonomaChannel key =
    Channel.init ("cotonomas:" ++ key)
        |> Channel.on "post"
            (\payload -> PostPushed payload)
        |> Channel.on "presence_state"
            (\payload -> CotonomaPresenceState payload)
        |> Channel.on "presence_diff"
            (\payload -> CotonomaPresenceDiff payload)


type alias Payload body =
    { clientId : ClientId
    , body : body
    }


decodePayload : String -> Decode.Decoder body -> Decode.Decoder (Payload body)
decodePayload bodyName bodyDecoder =
    Decode.map2 Payload
        (Decode.field "clientId" (Decode.map ClientId Decode.string))
        (Decode.field bodyName bodyDecoder)



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
    (List.map
        (\entry ->
            ( Tuple.first entry
            , Tuple.second entry |> List.length
            )
        )
        entries
    )
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
    (Decode.map2 (,)
        (Decode.field "joins" decodePresenceEntries)
        (Decode.field "leaves" decodePresenceEntries)
    )
        |> \decoder ->
            case Decode.decodeValue decoder payload of
                Ok decodedPayload ->
                    ( decodedPayload |> Tuple.first |> convertPresenceEntriesToConnCounts
                    , decodedPayload |> Tuple.second |> convertPresenceEntriesToConnCounts
                    )

                Err err ->
                    ( Dict.empty, Dict.empty )
