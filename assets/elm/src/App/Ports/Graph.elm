port module App.Ports.Graph exposing
    ( Edge
    , Model
    , Node
    , addSubgraph
    , defaultEdge
    , defaultNode
    , destroyGraph
    , initEdge
    , initEdgeFromLinkingPhrase
    , initEdgeToLinkingPhrase
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
    , subgraphLoaded : Bool
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
    , subgraphLoaded = True
    , incomings = 0
    , outgoings = 0
    }


type alias Edge =
    { id : String
    , source : String
    , target : String
    , toLinkingPhrase : Bool
    , fromLinkingPhrase : Bool
    }


defaultEdge : Edge
defaultEdge =
    { id = ""
    , source = ""
    , target = ""
    , toLinkingPhrase = False
    , fromLinkingPhrase = False
    }


initEdge : String -> String -> Edge
initEdge source target =
    { defaultEdge
        | id = source ++ "-" ++ target
        , source = source
        , target = target
    }


initEdgeToLinkingPhrase : String -> String -> Edge
initEdgeToLinkingPhrase source target =
    initEdge source target
        |> (\edge -> { edge | toLinkingPhrase = True })


initEdgeFromLinkingPhrase : String -> String -> Edge
initEdgeFromLinkingPhrase source target =
    initEdge source target
        |> (\edge -> { edge | fromLinkingPhrase = True })


type alias Model =
    { rootNodeId : String
    , nodes : List Node
    , edges : List Edge
    }


port renderGraph : Model -> Cmd msg


port addSubgraph : Model -> Cmd msg


port resizeGraph : () -> Cmd msg


port destroyGraph : () -> Cmd msg


port nodeClicked : (String -> msg) -> Sub msg
