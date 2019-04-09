port module App.Ports.Graph exposing
    ( Edge
    , Model
    , Node
    , defaultEdge
    , defaultNode
    , destroyGraph
    , nodeClicked
    , renderGraph
    , resizeGraph
    )


type alias Node =
    { id : String
    , label : String
    , pinned : Bool
    , asCotonoma : Bool
    , asLinkingPhrase : Bool
    , imageUrl : Maybe String
    , incomings : Int
    , outgoings : Int
    }


defaultNode : Node
defaultNode =
    { id = ""
    , label = ""
    , pinned = False
    , asCotonoma = False
    , asLinkingPhrase = False
    , imageUrl = Nothing
    , incomings = 0
    , outgoings = 0
    }


type alias Edge =
    { source : String
    , target : String
    , toLinkingPhrase : Bool
    , fromLinkingPhrase : Bool
    }


defaultEdge : Edge
defaultEdge =
    { source = ""
    , target = ""
    , toLinkingPhrase = False
    , fromLinkingPhrase = False
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
