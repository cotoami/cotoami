module Components.CotonomaModal.Model exposing (..)

import App.Types exposing (Amishi)


type Member = SignedUp Amishi | NotYetSignedUp String


type alias Model =
    { open : Bool
    , name : String
    , memberEmail : String
    , membersLoading : Bool
    , members : List Member
    }


initModel : Model
initModel =
    { open = False
    , name = ""
    , memberEmail = ""
    , membersLoading = False
    , members = []
    }
