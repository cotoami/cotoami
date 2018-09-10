module App.Submodels.Connecting
    exposing
        ( ConnectingTarget(..)
        , Connecting
        , connect
        )

import App.Types.Coto exposing (Coto)
import App.Types.Graph exposing (Graph, Direction(..))
import App.Types.Session exposing (Session)


type ConnectingTarget
    = Coto Coto
    | NewPost String (Maybe String)


type alias Connecting a =
    { a
        | graph : Graph
        , connectingTarget : Maybe ConnectingTarget
        , connectingDirection : Direction
    }


connect : Session -> Direction -> List Coto -> Coto -> Connecting a -> Connecting a
connect session direction cotos target connecting =
    let
        graph =
            connecting.graph
                |> App.Types.Graph.batchConnect session.id direction cotos target
    in
        { connecting
            | graph = graph
            , connectingTarget = Nothing
        }
