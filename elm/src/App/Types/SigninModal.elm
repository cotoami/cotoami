module App.Types.SigninModal exposing (..)


type alias SigninModal =
    { email : String
    , saveAnonymousCotos : Bool
    , requestProcessing : Bool
    , requestDone : Bool
    }


initSigninModel : SigninModal
initSigninModel =
    { email = ""
    , saveAnonymousCotos = False
    , requestProcessing = False
    , requestDone = False
    }
