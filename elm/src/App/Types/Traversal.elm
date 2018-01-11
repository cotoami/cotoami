module App.Types.Traversal exposing (..)

import Dict
import App.Types.Coto exposing (CotoId)


type alias Traversal =
    { start : CotoId
    , steps : List CotoId
    }


initTraversal : CotoId -> Traversal
initTraversal start =
    { start = start
    , steps = []
    }


traverse : Int -> CotoId -> Traversal -> Traversal
traverse stepIndex nextCotoId traversal =
    { traversal
        | steps =
            traversal.steps
                |> List.drop ((List.length traversal.steps) - (stepIndex + 1))
                |> (::) nextCotoId
    }


traverseToParent : CotoId -> Traversal -> Traversal
traverseToParent parentId traversal =
    { traversal
        | start = parentId
        , steps = traversal.steps ++ [ traversal.start ]
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
            Nothing ->
                False

            Just nextStep ->
                nextStep == cotoId


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


openTraversal : CotoId -> Traversals -> Traversals
openTraversal cotoId traversals =
    { traversals
        | entries = Dict.insert cotoId (initTraversal cotoId) traversals.entries
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


updateTraversal : CotoId -> Traversal -> Traversals -> Traversals
updateTraversal oldStartId newTraversal traversals =
    { traversals
        | entries =
            traversals.entries
                |> Dict.remove oldStartId
                |> Dict.insert newTraversal.start newTraversal
        , order =
            traversals.order
                |> List.map
                    (\cotoId ->
                        if cotoId == oldStartId then
                            newTraversal.start
                        else
                            cotoId
                    )
    }


isActiveIndex : Int -> Traversals -> Bool
isActiveIndex traversalIndex traversals =
    traversalIndex == traversals.activeIndexOnMobile
