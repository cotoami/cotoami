module App.Types exposing (..)


type alias Session =
    { id : Int
    , email : String
    , avatarUrl : String
    , displayName : String
    }


type alias Coto =
    { id : Int
    , content : String
    }


type alias Cotonoma =
    { id : Int
    , name : String
    }
