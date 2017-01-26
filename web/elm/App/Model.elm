module App.Model exposing (..)

import App.Types
import Components.ConfirmModal.Model
import Components.SigninModal
import Components.ProfileModal
import Components.Timeline.Model
import Components.CotoModal


type alias Model =
    { ctrlDown : Bool
    , session : Maybe App.Types.Session
    , confirmModal : Components.ConfirmModal.Model.Model
    , signinModal : Components.SigninModal.Model
    , profileModal : Components.ProfileModal.Model
    , cotoModal : Components.CotoModal.Model
    , timeline : Components.Timeline.Model.Model
    , activeCotoId : Maybe Int
    }


initModel : Model
initModel =
    { ctrlDown = False
    , session = Nothing
    , confirmModal = Components.ConfirmModal.Model.initModel
    , signinModal = Components.SigninModal.initModel
    , profileModal = Components.ProfileModal.initModel
    , cotoModal = Components.CotoModal.initModel
    , timeline = Components.Timeline.Model.initModel
    , activeCotoId = Nothing
    }
