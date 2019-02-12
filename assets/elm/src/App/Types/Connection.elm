module App.Types.Connection exposing
    ( Connection
    , Direction(..)
    , InboundConnection
    , Reordering(..)
    , inReordering
    , initConnection
    )

import App.Types.Amishi exposing (AmishiId)
import App.Types.Coto exposing (Coto, CotoId, ElementId)


type Direction
    = Outbound
    | Inbound


type alias Connection =
    { key : String
    , amishiId : AmishiId
    , start : Maybe CotoId
    , end : CotoId
    }


initConnection : AmishiId -> Maybe CotoId -> CotoId -> Connection
initConnection amishiId maybeStart end =
    let
        key =
            Maybe.withDefault "root" maybeStart ++ " -> " ++ end
    in
    Connection key amishiId maybeStart end


type Reordering
    = PinnedCoto ElementId
    | SubCoto ElementId ElementId


type alias InboundConnection =
    { parent : Maybe Coto
    , parentElementId : Maybe ElementId
    , connection : Connection
    , siblings : Int
    , index : Int
    , reordering : Bool
    }


inReordering : Maybe InboundConnection -> Bool
inReordering maybeInbound =
    Maybe.map .reordering maybeInbound
        |> Maybe.withDefault False
