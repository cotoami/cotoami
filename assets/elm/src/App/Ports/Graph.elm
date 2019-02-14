port module App.Ports.Graph exposing
    ( Edge
    , Node
    , destroyGraph
    , nodeClicked
    , renderGraph
    , resizeGraph
    )


port renderGraph :
    { rootNodeId : String, nodes : List Node, edges : List Edge }
    -> Cmd msg


port resizeGraph : () -> Cmd msg


port destroyGraph : () -> Cmd msg


port nodeClicked : (String -> msg) -> Sub msg


type alias Node =
    { id : String
    , name : String
    , pinned : Bool
    , asCotonoma : Bool
    , imageUrl : Maybe String
    }


type alias Edge =
    { source : String
    , target : String
    }
