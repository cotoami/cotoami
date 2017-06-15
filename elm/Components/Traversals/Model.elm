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
    }
      

initModel : Model
initModel =
    { traversals = Dict.empty
    , order = []
    }
    
    
openTraversal : CotoId -> Model -> Model
openTraversal cotoId model =
    if Dict.member cotoId model.traversals then
        model
    else
        { model
        | traversals = Dict.insert cotoId (initTraversal cotoId) model.traversals
        , order = cotoId :: model.order
        }
        
        
updateTraversal : Traversal -> Model -> Model
updateTraversal traversal model =
    { model
    | traversals = Dict.insert traversal.start traversal model.traversals 
    }
        
