module App.Messages exposing (Msg(..))

import Http
import Json.Encode exposing (Value)
import Keyboard exposing (..)
import Navigation exposing (Location)
import App.ActiveViewOnMobile exposing (ActiveViewOnMobile)
import App.Types.Coto exposing (Coto, ElementId, CotoId, Cotonoma, CotonomaKey)
import App.Types.Post exposing (Post)
import App.Types.Amishi exposing (Amishi)
import App.Types.Session exposing (Session)
import App.Types.Graph exposing (Direction, Graph)
import App.Types.Traversal exposing (Traverse)
import App.Modals.SigninModalMsg
import App.Modals.CotonomaModalMsg


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
      --
      -- Fetched
      --
    | SessionFetched (Result Http.Error Session)
    | RecentCotonomasFetched (Result Http.Error (List Cotonoma))
    | SubCotonomasFetched (Result Http.Error (List Cotonoma))
    | CotonomaFetched (Result Http.Error ( Cotonoma, List Amishi, List Post ))
    | GraphFetched (Result Http.Error Graph)
    | SubgraphFetched (Result Http.Error Graph)
      --
      -- Modal
      --
    | CloseModal
    | Confirm
    | OpenSigninModal
    | OpenProfileModal
    | OpenCotonomaModal
    | OpenCotoModal Coto
      --
      -- Coto
      --
    | CotoClick ElementId CotoId
    | CotoMouseEnter ElementId CotoId
    | CotoMouseLeave ElementId CotoId
    | SelectCoto CotoId
    | OpenTraversal CotoId
    | CotonomaClick CotonomaKey
    | ConfirmDeleteCoto
    | RequestDeleteCoto Coto
    | DeleteCoto Coto
    | CotoDeleted (Result Http.Error String)
    | PinCoto CotoId
    | CotoPinned (Result Http.Error String)
    | ConfirmUnpinCoto CotoId
    | UnpinCoto CotoId
    | CotoUnpinned (Result Http.Error String)
    | ConfirmConnect CotoId Direction
    | ReverseDirection
    | Connect Coto (List Coto) Direction
    | Connected (Result Http.Error (List String))
    | ConfirmDeleteConnection ( CotoId, CotoId )
    | DeleteConnection ( CotoId, CotoId )
    | ConnectionDeleted (Result Http.Error String)
      --
      -- Timeline
      --
    | PostsFetched (Result Http.Error (List Post))
    | ImageLoaded
    | EditorFocus
    | EditorBlur
    | EditorInput String
    | EditorKeyDown KeyCode
    | Post
    | Posted (Result Http.Error Post)
    | ConfirmPostAndConnect
    | PostAndConnect
    | PostedAndConnect (Result Http.Error Post)
    | PostCotonoma
    | CotonomaPosted (Result Http.Error Post)
    | OpenPost Post
    | PostPushed Value
    | CotonomaPushed Post
      --
      -- Traversals
      --
    | TraverseClick Traverse
    | CloseTraversal CotoId
    | SwitchTraversal Int
      --
      -- CotoSelection
      --
    | DeselectingCoto CotoId
    | DeselectCoto
    | ClearSelection
    | CotoSelectionColumnToggle
      --
      -- Sub components
      --
    | SigninModalMsg App.Modals.SigninModalMsg.Msg
    | CotonomaModalMsg App.Modals.CotonomaModalMsg.Msg
