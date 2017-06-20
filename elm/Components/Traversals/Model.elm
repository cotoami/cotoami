module Components.Traversals.Model exposing (..)

import Dict
import App.Types exposing (..)


type alias Traversal =
    { start : CotoId
    , steps : List CotoId
    }


type alias Traverse =
    { traversal : Traversal
    , startIndex : Int
    , endCotoId : CotoId
    }                


initTraversal : CotoId -> Traversal
initTraversal start =
    { start = start
    , steps = []
    }


doTraverse : Traverse -> Traversal
doTraverse traverse =
    let
        traversal = traverse.traversal
        stepsCount = List.length traversal.steps
    in
        { traversal
        | steps = 
            traversal.steps
            |> List.drop (stepsCount - (traverse.startIndex + 1))
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
      

type alias Model =
    { traversals : Dict.Dict CotoId Traversal
    , order : List CotoId
    , pageSize : Int
    , activePageIndex : Int
    }
      

initModel : Model
initModel =
    { traversals = Dict.empty
    , order = []
    , pageSize = 1
    , activePageIndex = 0
    }
    
    
isEmpty : Model -> Bool
isEmpty model =
    Dict.isEmpty model.traversals
    

size : Model -> Int
size model =
    Dict.size model.traversals
    
    
openTraversal : CotoId -> Model -> Model
openTraversal cotoId model =
    if Dict.member cotoId model.traversals then
        model
    else
        { model
        | traversals = Dict.insert cotoId (initTraversal cotoId) model.traversals
        , order = cotoId :: model.order
        , activePageIndex = 0
        }
  

removeTraversal : CotoId -> Model -> Model
removeTraversal cotoId model =   
    { model
    | traversals = Dict.remove cotoId model.traversals
    , order = List.filter (\id -> id /= cotoId) model.order
    }
        
        
updateTraversal : Traversal -> Model -> Model
updateTraversal traversal model =
    { model
    | traversals = Dict.insert traversal.start traversal model.traversals 
    }
    
    
countPages : Model -> Int
countPages model =
    ((size model) + model.pageSize - 1) // model.pageSize
    
    
inActivePage : Int -> Model -> Bool
inActivePage traversalIndex model =
    let
        startIndex = model.activePageIndex * model.pageSize
    in
        startIndex <= traversalIndex 
            && traversalIndex < startIndex + model.pageSize
    
        
