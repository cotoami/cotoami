module App.Types exposing (..)

import Json.Decode as Decode


type alias Session =
    { id : Int
    , email : String
    , avatarUrl : String
    , displayName : String
    }


decodeSession : Decode.Decoder Session
decodeSession =
    Decode.map4 Session
        (Decode.field "id" Decode.int)
        (Decode.field "email" Decode.string)
        (Decode.field "avatar_url" Decode.string)
        (Decode.field "display_name" Decode.string)
        
        
type alias Amishi =
    { id : Int
    , email : String
    , avatarUrl : String
    , displayName : String
    }


decodeAmishi : Decode.Decoder Amishi
decodeAmishi =
    Decode.map4 Amishi
        (Decode.field "id" Decode.int)
        (Decode.field "email" Decode.string)
        (Decode.field "avatar_url" Decode.string)
        (Decode.field "display_name" Decode.string)


type alias Coto =
    { id : Int
    , content : String
    , postedIn : Maybe Cotonoma
    , asCotonoma : Bool
    , cotonomaKey : String
    }


type alias Cotonoma =
    { id : Int
    , key : String
    , name : String
    }


decodeCotonoma : Decode.Decoder Cotonoma
decodeCotonoma =
    Decode.map3 Cotonoma
        (Decode.field "id" Decode.int)
        (Decode.field "key" Decode.string)
        (Decode.field "name" Decode.string)
