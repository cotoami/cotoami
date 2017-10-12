module App.Types.Session exposing (..)

import App.Types.Amishi exposing (Amishi, AmishiId)


type alias Session =
    { token : String
    , websocketUrl : String
    , id : AmishiId
    , email : String
    , owner : Bool
    , avatarUrl : String
    , displayName : String
    , lang : String
    }


toAmishi : Session -> Amishi
toAmishi session =
    Amishi
        session.id
        session.email
        session.owner
        session.avatarUrl
        session.displayName
