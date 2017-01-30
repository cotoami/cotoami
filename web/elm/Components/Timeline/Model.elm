module Components.Timeline.Model exposing (..)

type alias Coto =
    { id : Maybe Int
    , postId : Maybe Int
    , content : String
    , asCotonoma : Bool
    , beingDeleted : Bool
    }


defaultCoto : Coto
defaultCoto =
    { id = Nothing
    , postId = Nothing 
    , content = ""
    , asCotonoma = False
    , beingDeleted = False
    }


type alias Model =
    { editingNewCoto : Bool
    , newCotoContent : String
    , postIdCounter : Int
    , cotos : List Coto
    }


initModel : Model
initModel =
    { editingNewCoto = False
    , newCotoContent = ""
    , postIdCounter = 0
    , cotos = []
    }


updateCoto : (Coto -> Coto) -> Int -> List Coto -> List Coto
updateCoto update id cotos =
     List.map 
         (\coto -> 
             if coto.id == Just id then
                 update coto
             else
                 coto
         )
         cotos        
