module App.Model exposing (..)

import Components.SigninModal

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
    , signinModal : Components.SigninModal.Model
    }


initModel : Model
initModel =
    { session = Nothing
    , ctrlDown = False
    , editingNewCoto = False
    , newCoto = ""
    , cotos = []
    , signinModal = Components.SigninModal.initModel
    }
