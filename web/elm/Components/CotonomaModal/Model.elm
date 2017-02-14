module Components.CotonomaModal.Model exposing (..)


type alias Model =
    { open : Bool
    , name : String
    , memberEmail : String
    }


initModel : Model
initModel =
    { open = False
    , name = ""
    , memberEmail = ""
    }
