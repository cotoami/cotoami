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
    , cotoSelection : CotoSelection
    , connectMode : Bool
    , connectingTo : Maybe Int
    , connectModalOpen : Bool
    , cotonomaModal : Components.CotonomaModal.Model.Model
    , stockToggled : Bool
    , stockOpen : Bool
    , connections : Components.Connections.Model.Model
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
        , cotoSelection = []
        , connectMode = False
        , connectingTo = Nothing
        , connectModalOpen = False
        , cotonomaModal = Components.CotonomaModal.Model.initModel
        , stockToggled = False
        , stockOpen = False
        , connections = Components.Connections.Model.initModel
        }


getCoto : Int ->  Model -> Maybe Coto
getCoto cotoId model =
    case Dict.get cotoId model.connections.cotos of
        Nothing ->
            Components.Timeline.Model.getCoto cotoId model.timeline
        Just coto ->
            Just coto


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
