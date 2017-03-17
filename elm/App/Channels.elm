module App.Channels exposing (..)

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
