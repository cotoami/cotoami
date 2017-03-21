module App.Channels exposing (..)

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


type alias Payload body =
    { clientId : String
    , body : body
    }


decodePayload : String -> Decode.Decoder body -> Decode.Decoder (Payload body)
decodePayload bodyName bodyDecoder =
    Decode.map2 Payload
        (Decode.field "clientId" Decode.string)
        (Decode.field bodyName bodyDecoder)
