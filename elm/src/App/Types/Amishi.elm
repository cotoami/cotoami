module App.Types.Amishi exposing (..)


type alias AmishiId = String


type alias Amishi =
    { id : AmishiId
    , email : String
    , avatarUrl : String
    , displayName : String
    }
