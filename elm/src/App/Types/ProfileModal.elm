module App.Types.ProfileModal exposing (..)

type alias ProfileModal =
    { open : Bool
    }

initProfileModel : ProfileModal
initProfileModel =
    { open = False
    }
