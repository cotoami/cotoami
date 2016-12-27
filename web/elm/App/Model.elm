module App.Model exposing (..)

type alias Session =
    { id : Int
    , email : String
    , avatarUrl : String
    , displayName : String
    }


type alias Coto =
    { content : String
    }


type alias Model =
    { session : Maybe Session
    , ctrlDown : Bool
    , editingNewCoto : Bool
    , newCoto : String
    , cotos : List Coto
    , showSigninModal : Bool
    , signinEmail : String
    , signinWithAnonymousCotos : Bool
    , signinRequestProcessing : Bool
    , signinRequestDone : Bool
    }


initModel : Model
initModel =
    { session = Nothing
    , ctrlDown = False
    , editingNewCoto = False
    , newCoto = ""
    , cotos = []
    , showSigninModal = False
    , signinEmail = ""
    , signinWithAnonymousCotos = False
    , signinRequestProcessing = False
    , signinRequestDone = False
    }
