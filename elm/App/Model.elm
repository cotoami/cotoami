module App.Model exposing (..)

import Dict
import Uuid
import Random.Pcg exposing (initialSeed, step)
import Exts.Maybe exposing (isNothing)
import App.Types exposing (..)
import Components.ConfirmModal.Model
import Components.SigninModal
import Components.ProfileModal
import Components.Timeline.Model
import Components.CotoModal
import Components.CotonomaModal.Model
import Components.Connections.Model


type alias ConnectMode =
    { baseCotoId : Int
    , otherCotoIds : List Int
    }


type alias Model =
    { clientId : String
    , route : Route
    , ctrlDown : Bool
    , navigationToggled : Bool
    , navigationOpen : Bool
    , session : Maybe Session
    , cotonoma : Maybe Cotonoma
    , members : List Amishi
    , memberPresences : MemberConnCounts
    , confirmModal : Components.ConfirmModal.Model.Model
    , signinModal : Components.SigninModal.Model
    , profileModal : Components.ProfileModal.Model
    , cotoModal : Components.CotoModal.Model
    , recentCotonomas : List Cotonoma
    , cotonomasLoading : Bool
    , subCotonomas : List Cotonoma
    , timeline : Components.Timeline.Model.Model
    , activeCotoId : Maybe Int
    , cotonomaModal : Components.CotonomaModal.Model.Model
    , stockToggled : Bool
    , stockOpen : Bool
    , connections : Components.Connections.Model.Model
    , connectMode : Maybe ConnectMode
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
        , members = []
        , memberPresences = Dict.empty
        , confirmModal = Components.ConfirmModal.Model.initModel
        , signinModal = Components.SigninModal.initModel
        , profileModal = Components.ProfileModal.initModel
        , cotoModal = Components.CotoModal.initModel
        , recentCotonomas = []
        , cotonomasLoading = False
        , subCotonomas = []
        , timeline = Components.Timeline.Model.initModel
        , activeCotoId = Nothing
        , cotonomaModal = Components.CotonomaModal.Model.initModel
        , stockToggled = False
        , stockOpen = False
        , connections = Components.Connections.Model.initModel
        , connectMode = Nothing
        }


openSigninModal : Model -> Model
openSigninModal model =
    let
        signinModal = model.signinModal
    in
        { model | signinModal = { signinModal | open = True } }
        

isPresent : Int -> MemberConnCounts -> Bool
isPresent amishiId memberPresences =
    (Dict.get amishiId memberPresences |> Maybe.withDefault 0) > 0
    

isNavigationEmpty : Model -> Bool
isNavigationEmpty model =
    (isNothing model.cotonoma)
        && (List.isEmpty model.recentCotonomas) 
        && (List.isEmpty model.subCotonomas)
        
        
isStockEmpty : Model -> Bool
isStockEmpty model =
      List.isEmpty model.connections.rootConnections
        
        
getOwnerAndMembers : Model -> List Amishi
getOwnerAndMembers model =
    case model.cotonoma of
        Nothing -> []
        Just cotonoma ->
            case cotonoma.owner of
                Nothing -> model.members
                Just owner -> owner :: model.members
