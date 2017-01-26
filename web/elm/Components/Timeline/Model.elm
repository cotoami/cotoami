module Components.Timeline.Model exposing (..)

type alias Coto =
    { id : Maybe Int
    , postId : Maybe Int
    , content : String
    , beingDeleted : Bool
    }


defaultCoto : Coto
defaultCoto =
    { id = Nothing
    , postId = Nothing 
    , content = ""
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
