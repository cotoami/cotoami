module App.Types.Traversal exposing (..)

import Dict
import App.Types.Coto exposing (CotoId)


type Description
    = Connected
    | Opened


type alias Traversal =
    { description : Description
    , start : CotoId
    , steps : List CotoId
    }


type alias Traverse =
    { traversal : Traversal
    , startIndex : Int
    , endCotoId : CotoId
    }


initTraversal : Description -> CotoId -> Traversal
initTraversal description start =
    { description = description
    , start = start
    , steps = []
    }


doTraverse : Traverse -> Traversal
doTraverse traverse =
    traverse.traversal
        |> \traversal ->
            { traversal
            | steps = traversal.steps
                |> List.drop ((List.length traversal.steps) - (traverse.startIndex + 1))
                |> (::) traverse.endCotoId
            }


traversed : Int -> CotoId -> Traversal -> Bool
traversed index cotoId traversal =
    let
        steps =
          if index < 0 then
              traversal.steps |> List.reverse
          else
              traversal.steps |> List.reverse |> List.drop (index + 1)

    in
        case List.head steps of
            Nothing -> False
            Just nextStep -> nextStep == cotoId


type alias Traversals =
    { entries : Dict.Dict CotoId Traversal
    , order : List CotoId
    , activeIndexOnMobile : Int
    }


defaultTraversals : Traversals
defaultTraversals =
    { entries = Dict.empty
    , order = []
    , activeIndexOnMobile = 0
    }


isEmpty : Traversals -> Bool
isEmpty traversals =
    Dict.isEmpty traversals.entries


size : Traversals -> Int
size traversals =
    Dict.size traversals.entries


openTraversal : Description -> CotoId -> Traversals -> Traversals
openTraversal description cotoId traversals =
    { traversals
    | entries = Dict.insert cotoId (initTraversal description cotoId) traversals.entries
    , order =
        traversals.order
        |> List.filter (\id -> id /= cotoId)
        |> (::) cotoId
    , activeIndexOnMobile = 0
    }


closeTraversal : CotoId -> Traversals -> Traversals
closeTraversal cotoId traversals =
    { traversals
    | entries = Dict.remove cotoId traversals.entries
    , order = List.filter (\id -> id /= cotoId) traversals.order
    }


updateTraversal : Traversal -> Traversals -> Traversals
updateTraversal traversal traversals =
    { traversals
    | entries = Dict.insert traversal.start traversal traversals.entries
    }


isActiveIndex : Int -> Traversals -> Bool
isActiveIndex traversalIndex traversals =
    traversalIndex == traversals.activeIndexOnMobile
