module App.Types exposing (..)

import Json.Decode as Decode
        
        
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


toAmishi : Session -> Amishi
toAmishi session =
    Amishi
        session.id
        session.email
        session.avatarUrl
        session.displayName


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
    , cotoId : Int
    }


decodeCotonoma : Decode.Decoder Cotonoma
decodeCotonoma =
    Decode.map4 Cotonoma
        (Decode.field "id" Decode.int)
        (Decode.field "key" Decode.string)
        (Decode.field "name" Decode.string)
        (Decode.field "coto_id" Decode.int)
