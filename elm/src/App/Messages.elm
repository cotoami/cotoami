module App.Messages exposing (Msg(..))

import Http
import Json.Encode exposing (Value)
import Keyboard exposing (..)
import Navigation exposing (Location)
import App.ActiveViewOnMobile exposing (ActiveViewOnMobile)
import App.Types.Coto exposing (Coto, CotoId, Cotonoma, CotonomaKey)
import App.Types.Post exposing (Post)
import App.Types.Amishi exposing (Amishi)
import App.Types.Session exposing (Session)
import App.Types.Graph exposing (Graph)
import App.Types.Traversal exposing (Traverse)
import Components.ConfirmModal.Messages
import Components.SigninModal
import Components.ProfileModal
import Components.CotoModal
import Components.CotonomaModal.Messages
import Components.CotoSelection.Messages


type Msg
    = NoOp
    | KeyDown KeyCode
    | KeyUp KeyCode
    | OnLocationChange Location
    | NavigationToggle
    | SwitchViewOnMobile ActiveViewOnMobile
    | HomeClick
    | CotonomaPresenceState Value
    | CotonomaPresenceDiff Value

    -- Fetched
    | SessionFetched (Result Http.Error Session)
    | RecentCotonomasFetched (Result Http.Error (List Cotonoma))
    | SubCotonomasFetched (Result Http.Error (List Cotonoma))
    | CotonomaFetched (Result Http.Error (Cotonoma, List Amishi, List Post))
    | GraphFetched (Result Http.Error Graph)
    | SubgraphFetched (Result Http.Error Graph)

    -- Modal
    | OpenSigninModal
    | OpenProfileModal
    | OpenCotonomaModal
    | CloseConnectModal

    -- Coto
    | CotoClick CotoId
    | CotoMouseEnter CotoId
    | CotoMouseLeave CotoId
    | OpenCoto Coto
    | SelectCoto CotoId
    | OpenTraversal CotoId
    | CotonomaClick CotonomaKey
    | DeleteCoto Coto
    | CotoDeleted (Result Http.Error String)
    | ConfirmUnpinCoto CotoId
    | UnpinCoto CotoId
    | CotoUnpinned (Result Http.Error String)
    | Connect Coto (List Coto)
    | Connected (Result Http.Error String)
    | ConfirmDeleteConnection ( CotoId, CotoId )
    | DeleteConnection ( CotoId, CotoId )
    | ConnectionDeleted (Result Http.Error String)

    -- Timeline
    | PostsFetched (Result Http.Error (List Post))
    | ImageLoaded
    | EditorFocus
    | EditorBlur
    | EditorInput String
    | EditorKeyDown KeyCode
    | Post
    | Posted (Result Http.Error Post)
    | OpenPost Post
    | PostPushed Value
    | CotonomaPushed Post

    -- Traversals
    | TraverseClick Traverse
    | CloseTraversal CotoId
    | ChangePage Int

    -- Sub components
    | ConfirmModalMsg Components.ConfirmModal.Messages.Msg
    | SigninModalMsg Components.SigninModal.Msg
    | ProfileModalMsg Components.ProfileModal.Msg
    | CotoModalMsg Components.CotoModal.Msg
    | CotonomaModalMsg Components.CotonomaModal.Messages.Msg
    | CotoSelectionMsg Components.CotoSelection.Messages.Msg
