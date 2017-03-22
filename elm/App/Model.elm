module App.Model exposing (..)

import Uuid
import Random.Pcg exposing (initialSeed, step)
import App.Types exposing (Route, CotonomaKey)
import Components.ConfirmModal.Model
import Components.SigninModal
import Components.ProfileModal
import Components.Timeline.Model
import Components.CotoModal
import Components.CotonomaModal.Model


type alias Model =
    { clientId : String
    , route : Route
    , ctrlDown : Bool
    , navigationToggled : Bool
    , navigationOpen : Bool
    , session : Maybe App.Types.Session
    , cotonoma : Maybe App.Types.Cotonoma
    , confirmModal : Components.ConfirmModal.Model.Model
    , signinModal : Components.SigninModal.Model
    , profileModal : Components.ProfileModal.Model
    , cotoModal : Components.CotoModal.Model
    , cotonomas : List App.Types.Cotonoma
    , cotonomasLoading : Bool
    , timeline : Components.Timeline.Model.Model
    , activeCotoId : Maybe Int
    , cotonomaModal : Components.CotonomaModal.Model.Model
    }


initModel : Int -> Route -> Model
initModel seed route =
    let
        ( newUuid, newSeed ) = step Uuid.uuidGenerator (initialSeed seed)
    in
        { clientId = Uuid.toString newUuid
        , route = route
        , ctrlDown = False
        , navigationToggled = False
        , navigationOpen = False
        , session = Nothing
        , cotonoma = Nothing
        , confirmModal = Components.ConfirmModal.Model.initModel
        , signinModal = Components.SigninModal.initModel
        , profileModal = Components.ProfileModal.initModel
        , cotoModal = Components.CotoModal.initModel
        , cotonomas = []
        , cotonomasLoading = True
        , timeline = Components.Timeline.Model.initModel
        , activeCotoId = Nothing
        , cotonomaModal = Components.CotonomaModal.Model.initModel
        }
