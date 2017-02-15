module Components.CotonomaModal.Model exposing (..)

import App.Types exposing (Amishi)


type Member = SignedUp Amishi | NotYetSignedUp String


type alias Model =
    { open : Bool
    , name : String
    , memberEmail : String
    , memberEmailValid : Bool
    , membersLoading : Bool
    , members : List Member
    }


initModel : Model
initModel =
    { open = False
    , name = ""
    , memberEmail = ""
    , memberEmailValid = False
    , membersLoading = False
    , members = []
    }


addMember : Model -> Member -> Model
addMember model member =
    { model 
    | members = member :: model.members
    , membersLoading = False
    , memberEmail = ""
    , memberEmailValid = False
    }
