module App.Messages exposing (Msg(..))

import Http
import Keyboard exposing (..)
import App.Types exposing (Session)
import Components.ConfirmModal.Messages
import Components.SigninModal
import Components.ProfileModal
import Components.Timeline.Messages
import Components.CotoModal
import Components.CotonomaModal


type Msg
    = NoOp
    | SessionFetched (Result Http.Error Session)
    | KeyDown KeyCode
    | KeyUp KeyCode
    | ConfirmModalMsg Components.ConfirmModal.Messages.Msg
    | OpenSigninModal
    | SigninModalMsg Components.SigninModal.Msg
    | OpenProfileModal
    | ProfileModalMsg Components.ProfileModal.Msg
    | TimelineMsg Components.Timeline.Messages.Msg
    | CotoModalMsg Components.CotoModal.Msg
    | DeleteCoto Int
    | CotoDeleted (Result Http.Error String)
    | OpenCotonomaModal
    | CotonomaModalMsg Components.CotonomaModal.Msg
