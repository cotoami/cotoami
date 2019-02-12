module App.Types.Session exposing
    ( AuthSettings
    , Session
    , defaultAuthSettings
    )

import App.Types.Amishi exposing (Amishi)


type alias Session =
    { amishi : Amishi
    , token : String
    , websocketUrl : String
    , lang : String
    }


type alias AuthSettings =
    { signupEnabled : Bool
    , oauthProviders : List String
    }


defaultAuthSettings : AuthSettings
defaultAuthSettings =
    { signupEnabled = False
    , oauthProviders = []
    }
