module App.Types.Traversal exposing
    ( Traversal
    , Traversals
    , closeTraversal
    , defaultTraversals
    , initTraversal
    , isActiveIndex
    , isEmpty
    , openTraversal
    , setActiveIndexOnMobile
    , size
    , traverse
    , traverseToParent
    , traversed
    , updateTraversal
    )

import App.Types.Coto exposing (CotoId)
import App.Types.Graph exposing (Graph)
import Dict
import List.Extra


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
                |> List.drop (List.length traversal.steps - (stepIndex + 1))
                |> (::) nextCotoId
    }


traverseToParent : Graph -> CotoId -> Traversal -> Traversal
traverseToParent graph parentId traversal =
    { traversal
        | start = parentId
        , steps =
            if App.Types.Graph.hasChildren traversal.start graph then
                traversal.steps ++ [ traversal.start ]

            else
                traversal.steps
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
    List.head steps
        |> Maybe.map (\nextStep -> nextStep == cotoId)
        |> Maybe.withDefault False


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


setActiveIndexOnMobile : Int -> Traversals -> Traversals
setActiveIndexOnMobile index traversals =
    { traversals | activeIndexOnMobile = index }


isEmpty : Traversals -> Bool
isEmpty traversals =
    Dict.isEmpty traversals.entries


size : Traversals -> Int
size traversals =
    Dict.size traversals.entries


openTraversal : CotoId -> Traversals -> Traversals
openTraversal cotoId traversals =
    let
        entries =
            traversals.entries
                |> Dict.insert cotoId (initTraversal cotoId)

        order =
            traversals.order
                |> List.filter (\id -> id /= cotoId)
                |> (::) cotoId

        activeIndexOnMobile =
            List.length order - 1
    in
    { traversals
        | entries = entries
        , order = order
        , activeIndexOnMobile = activeIndexOnMobile
    }


updateTraversal : CotoId -> Traversal -> Traversals -> Traversals
updateTraversal oldStartId newTraversal traversals =
    let
        entries =
            traversals.entries
                |> Dict.remove oldStartId
                |> Dict.insert newTraversal.start newTraversal

        order =
            if newTraversal.start == oldStartId then
                traversals.order

            else
                traversals.order
                    |> List.filter (\cotoId -> cotoId /= newTraversal.start)
                    |> List.map
                        (\cotoId ->
                            if cotoId == oldStartId then
                                newTraversal.start

                            else
                                cotoId
                        )

        activeIndexOnMobile =
            order
                |> List.reverse
                |> List.Extra.elemIndex newTraversal.start
                |> Maybe.withDefault 0
    in
    { traversals
        | entries = entries
        , order = order
        , activeIndexOnMobile = activeIndexOnMobile
    }


closeTraversal : CotoId -> Traversals -> Traversals
closeTraversal cotoId traversals =
    { traversals
        | entries = Dict.remove cotoId traversals.entries
        , order = List.filter (\id -> id /= cotoId) traversals.order
        , activeIndexOnMobile = 0
    }


isActiveIndex : Int -> Traversals -> Bool
isActiveIndex traversalIndex traversals =
    traversalIndex == traversals.activeIndexOnMobile
