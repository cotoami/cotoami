module App.Channels exposing (..)

import Dict
import Json.Encode exposing (Value)
import Json.Decode as Decode
import Phoenix.Channel as Channel exposing (Channel)
import App.Types exposing (CotonomaKey, MemberConnCounts)
import App.Messages exposing (..)
import Components.Timeline.Messages


cotonomaChannel : CotonomaKey -> Channel Msg
cotonomaChannel key =
    Channel.init ("cotonomas:" ++ key)
        |> Channel.on "post" 
            (\payload -> 
                TimelineMsg (Components.Timeline.Messages.PostPushed payload)
            )
        |> Channel.on "presence_state" 
            (\payload -> CotonomaPresenceState payload)
        |> Channel.on "presence_diff" 
            (\payload -> CotonomaPresenceDiff payload)


type alias Payload body =
    { clientId : String
    , body : body
    }


decodePayload : String -> Decode.Decoder body -> Decode.Decoder (Payload body)
decodePayload bodyName bodyDecoder =
    Decode.map2 Payload
        (Decode.field "clientId" Decode.string)
        (Decode.field bodyName bodyDecoder)


-- https://hexdocs.pm/phoenix/Phoenix.Presence.html
-- {3: {metas: [{phx_ref: "5OaVq4AmYbU=", online_at: 1490350876053}]}}
type alias PresenceEntry = ( String, List ( String, List ( String, Int ) ) )


decodePresenceEntries : Decode.Decoder (List PresenceEntry)
decodePresenceEntries =
    Decode.keyValuePairs          -- Amishi ID
        <| Decode.keyValuePairs   -- "metas"
        <| Decode.list            
        <| Decode.map2 (,)
            (Decode.field "phx_ref" Decode.string)
            (Decode.field "online_at" Decode.int)


convertPresenceEntriesToDict : List PresenceEntry -> MemberConnCounts
convertPresenceEntriesToDict entries =
    (List.map 
        (\entry -> 
            ( Tuple.first entry |> String.toInt |> Result.withDefault 0
            , Tuple.second entry |> List.length
            )
        ) 
        entries
    ) |> Dict.fromList


decodePresenceState : Value -> MemberConnCounts
decodePresenceState payload =
    case Decode.decodeValue decodePresenceEntries payload of
        Ok decodedPayload ->
            convertPresenceEntriesToDict decodedPayload
        Err err ->
            Dict.empty
        

-- https://hexdocs.pm/phoenix/Phoenix.Presence.html
-- {leaves: {3: {metas: [{phx_ref: "7h9YpxuqCmM=", online_at: 1490350421829}]}}, joins: {}}
decodePresenceDiff : Value -> ( MemberConnCounts, MemberConnCounts )
decodePresenceDiff payload =
    let
        decoder =
            Decode.map2 (,)
                (Decode.field "joins" decodePresenceEntries)
                (Decode.field "leaves" decodePresenceEntries)
    in
        case Decode.decodeValue decoder payload of
            Ok decodedPayload ->
                ( decodedPayload |> Tuple.first  |> convertPresenceEntriesToDict
                , decodedPayload |> Tuple.second  |> convertPresenceEntriesToDict
                )
            Err err ->
                ( Dict.empty, Dict.empty )
