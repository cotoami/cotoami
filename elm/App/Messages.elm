module App.Messages exposing (Msg(..))

import Http
import Json.Encode exposing (Value)
import Keyboard exposing (..)
import Navigation exposing (Location)
import App.Types exposing (Session, Amishi, Coto, CotoId, Cotonoma, CotonomaKey, ViewInMobile)
import Components.ConfirmModal.Messages
import Components.SigninModal
import Components.ProfileModal
import Components.Timeline.Model exposing (Post)
import Components.Timeline.Messages
import Components.CotoModal
import Components.CotonomaModal.Messages
import Components.Traversals.Messages


type Msg
    = NoOp
    | OnLocationChange Location
    | NavigationToggle
    | SwitchViewInMobile ViewInMobile
    | SessionFetched (Result Http.Error Session)
    | RecentCotonomasFetched (Result Http.Error (List Cotonoma))
    | SubCotonomasFetched (Result Http.Error (List Cotonoma))
    | HomeClick
    | CotonomaFetched (Result Http.Error (Cotonoma, List Amishi, List Post))
    | KeyDown KeyCode
    | KeyUp KeyCode
    | ConfirmModalMsg Components.ConfirmModal.Messages.Msg
    | OpenSigninModal
    | SigninModalMsg Components.SigninModal.Msg
    | OpenProfileModal
    | ProfileModalMsg Components.ProfileModal.Msg
    | TimelineMsg Components.Timeline.Messages.Msg
    | CotoModalMsg Components.CotoModal.Msg
    | DeleteCoto Coto
    | CotoDeleted (Result Http.Error String)
    | OpenCotonomaModal
    | CotonomaModalMsg Components.CotonomaModal.Messages.Msg
    | CotoClick CotoId
    | OpenCoto Coto
    | OpenTraversal CotoId
    | CotonomaClick CotonomaKey
    | CotonomaPresenceState Value
    | CotonomaPresenceDiff Value
    | ConfirmPin
    | Pin
    | ClearSelection
    | SetConnectMode Bool
    | CloseConnectModal
    | Connect Coto (List Coto)
    | CotoSelectionTitleInput String
    | TraversalMsg Components.Traversals.Messages.Msg
    
