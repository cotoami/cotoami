module App.Types exposing (..)


type alias Session =
    { id : Int
    , email : String
    , avatarUrl : String
    , displayName : String
    }
