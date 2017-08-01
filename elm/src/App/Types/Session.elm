module App.Types.Session exposing (..)

import App.Types.Amishi exposing (Amishi, AmishiId)


type alias Session =
    { token : String
    , websocketUrl : String
    , id : AmishiId
    , email : String
    , avatarUrl : String
    , displayName : String
    }


toAmishi : Session -> Amishi
toAmishi session =
    Amishi
        session.id
        session.email
        session.avatarUrl
        session.displayName
