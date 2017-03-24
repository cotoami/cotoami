module App.Channels exposing (..)

import Set exposing (Set, fromList)
import Json.Encode exposing (Value)
import Json.Decode as Decode
import Phoenix.Channel as Channel exposing (Channel)
import App.Types exposing (CotonomaKey)
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


type alias PresenceEntry = ( String, List ( String, List ( String, Int ) ) )

decodePresenceEntries : Decode.Decoder (List PresenceEntry)
decodePresenceEntries =
    Decode.keyValuePairs          -- Amishi ID
        <| Decode.keyValuePairs   -- "metas"
        <| Decode.list            
        <| Decode.map2 (,)
            (Decode.field "phx_ref" Decode.string)
            (Decode.field "online_at" Decode.int)


convertPresenceEntriesToIds : List PresenceEntry -> Set Int
convertPresenceEntriesToIds entries =
    (List.map 
        (\entry -> Tuple.first entry |> String.toInt |> Result.withDefault 0) 
        entries
    ) |> fromList


decodePresenceState : Value -> Set Int
decodePresenceState payload =
    case Decode.decodeValue decodePresenceEntries payload of
        Ok decodedPayload ->
            convertPresenceEntriesToIds decodedPayload
        Err err ->
            fromList []
        
    
decodePresenceDiff : Value -> ( Set Int, Set Int )
decodePresenceDiff payload =
    let
        decoder =
            Decode.map2 (,)
                (Decode.field "joins" decodePresenceEntries)
                (Decode.field "leaves" decodePresenceEntries)
    in
        case Decode.decodeValue decoder payload of
            Ok decodedPayload ->
                ( decodedPayload |> Tuple.first  |> convertPresenceEntriesToIds
                , decodedPayload |> Tuple.second  |> convertPresenceEntriesToIds
                )
            Err err ->
                ( fromList [], fromList [] )
