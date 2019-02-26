module App.Types.Connection exposing
    ( Connection
    , Direction(..)
    , InboundConnection
    , Reordering(..)
    , canUpdate
    , inReordering
    , makeUniqueKey
    , setLinkingPhrase
    )

import App.Types.Amishi exposing (AmishiId)
import App.Types.Coto exposing (Coto, CotoId, ElementId)
import App.Types.Session exposing (Session)


type Direction
    = Outbound
    | Inbound


type alias Connection =
    { start : Maybe CotoId
    , end : CotoId
    , linkingPhrase : Maybe String
    , amishiId : AmishiId
    }


makeUniqueKey : Connection -> String
makeUniqueKey connection =
    let
        start =
            connection.start |> Maybe.withDefault "root"
    in
    start ++ "_" ++ connection.end


setLinkingPhrase : Maybe String -> Connection -> Connection
setLinkingPhrase linkingPhrase connection =
    { connection | linkingPhrase = linkingPhrase }


canUpdate : Session -> Coto -> Connection -> Bool
canUpdate session startCoto connection =
    session.amishi.owner
        || (session.amishi.id == connection.amishiId)
        || (Just session.amishi.id == Maybe.map .id startCoto.amishi)


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
