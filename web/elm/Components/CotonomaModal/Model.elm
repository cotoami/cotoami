module Components.CotonomaModal.Model exposing (..)


type alias Model =
    { open : Bool
    , name : String
    , memberEmail : String
    , membersLoading : Bool
    }


initModel : Model
initModel =
    { open = False
    , name = ""
    , memberEmail = ""
    , membersLoading = False
    }
