module App.Types.Session
    exposing
        ( Session
        , toAmishi
        , AuthSettings
        , defaultAuthSettings
        )

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


type alias AuthSettings =
    { signupEnabled : Bool
    , oauthProviders : List String
    }


defaultAuthSettings : AuthSettings
defaultAuthSettings =
    { signupEnabled = False
    , oauthProviders = []
    }
