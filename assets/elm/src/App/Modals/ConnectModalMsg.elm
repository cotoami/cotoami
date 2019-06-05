module App.Modals.ConnectModalMsg exposing (Msg(..))

import App.Types.Coto exposing (Coto, CotoContent)
import App.Types.Post exposing (Post)
import Http


type Msg
    = ReverseDirection
    | LinkingPhraseInput String
    | Connect Coto
    | PostAndConnectToSelection CotoContent
    | PostedAndConnectToSelection Int (Result Http.Error Post)
