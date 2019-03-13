port module App.Ports.Graph exposing
    ( Edge
    , Model
    , Node
    , destroyGraph
    , nodeClicked
    , renderGraph
    , resizeGraph
    )


type alias Node =
    { id : String
    , name : String
    , pinned : Bool
    , asCotonoma : Bool
    , imageUrl : Maybe String
    , incoming : Int
    , outgoing : Int
    }


type alias Edge =
    { source : String
    , target : String
    , linkingPhrase : Maybe String
    }


type alias Model =
    { rootNodeId : String
    , nodes : List Node
    , edges : List Edge
    }


port renderGraph : Model -> Cmd msg


port resizeGraph : () -> Cmd msg


port destroyGraph : () -> Cmd msg


port nodeClicked : (String -> msg) -> Sub msg
