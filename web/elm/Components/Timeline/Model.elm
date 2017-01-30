module Components.Timeline.Model exposing (..)

import Json.Decode as Decode
import App.Types exposing (Cotonoma, decodeCotonoma)


type alias Coto =
    { id : Maybe Int
    , postId : Maybe Int
    , content : String
    , postedIn : Maybe Cotonoma
    , asCotonoma : Bool
    , cotonomaKey : String
    , beingDeleted : Bool
    }


defaultCoto : Coto
defaultCoto =
    { id = Nothing
    , postId = Nothing 
    , content = ""
    , postedIn = Nothing
    , asCotonoma = False
    , cotonomaKey = ""
    , beingDeleted = False
    }


decodeCoto : Decode.Decoder Coto
decodeCoto =
    Decode.map7 Coto
        (Decode.maybe (Decode.field "id" Decode.int))
        (Decode.maybe (Decode.field "postId" Decode.int))
        (Decode.field "content" Decode.string)
        (Decode.maybe (Decode.field "posted_in" decodeCotonoma))
        (Decode.field "as_cotonoma" Decode.bool)
        (Decode.field "cotonoma_key" Decode.string)
        (Decode.succeed False)


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
