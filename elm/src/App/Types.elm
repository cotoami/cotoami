module App.Types exposing (..)

import Set
import Dict
import Json.Decode as Decode
import Exts.Maybe exposing (isNothing)
import App.Types.Amishi exposing (..)


type Route
    = HomeRoute
    | CotonomaRoute CotonomaKey
    | NotFoundRoute


type ViewInMobile
    = TimelineView
    | PinnedView
    | TraversalsView
    | SelectionView


type alias Session =
    { token : String
    , websocketUrl : String
    , id : AmishiId
    , email : String
    , avatarUrl : String
    , displayName : String
    }


decodeSession : Decode.Decoder Session
decodeSession =
    Decode.map6 Session
        (Decode.field "token" Decode.string)
        (Decode.field "websocket_url" Decode.string)
        (Decode.field "id" Decode.string)
        (Decode.field "email" Decode.string)
        (Decode.field "avatar_url" Decode.string)
        (Decode.field "display_name" Decode.string)


toAmishi : Session -> Amishi
toAmishi session =
    Amishi
        session.id
        session.email
        session.avatarUrl
        session.displayName


type alias CotoId = String


type alias CotonomaKey = String


type alias Coto =
    { id : CotoId
    , content : String
    , postedIn : Maybe Cotonoma
    , asCotonoma : Bool
    , cotonomaKey : CotonomaKey
    }


type alias Cotonoma =
    { id : String
    , key : CotonomaKey
    , name : String
    , cotoId : CotoId
    , owner : Maybe Amishi
    }


decodeCotonoma : Decode.Decoder Cotonoma
decodeCotonoma =
    Decode.map5 Cotonoma
        (Decode.field "id" Decode.string)
        (Decode.field "key" Decode.string)
        (Decode.field "name" Decode.string)
        (Decode.field "coto_id" Decode.string)
        (Decode.maybe (Decode.field "owner" decodeAmishi))


isPostedInCotonoma : Maybe Cotonoma -> Coto -> Bool
isPostedInCotonoma maybeCotonoma coto =
    case maybeCotonoma of
        Nothing ->
            isNothing coto.postedIn
        Just cotonoma ->
            case coto.postedIn of
                Nothing -> False
                Just postedIn -> postedIn.id == cotonoma.id


type alias CotoSelection = List CotoId


type alias Context =
    { clientId : String
    , session : Maybe Session
    , cotonoma : Maybe Cotonoma
    , focus : Maybe CotoId
    , selection : CotoSelection
    , deselecting : Set.Set CotoId
    , ctrlDown : Bool
    }


setFocus : Maybe CotoId -> Context -> Context
setFocus maybeCotoId context =
    { context | focus = maybeCotoId }


updateFocus : CotoId -> Context -> Context
updateFocus cotoId context =
    { context
    | focus =
        case context.focus of
            Nothing -> Just cotoId
            Just focus ->
                if focus == cotoId then
                    Nothing
                else
                    Just cotoId
    }


isSelected : CotoId -> Context -> Bool
isSelected cotoId context =
    List.member cotoId context.selection


updateSelection : CotoId -> Context -> Context
updateSelection cotoId context =
    { context
    | selection =
        if context.selection |> List.member cotoId  then
            List.filter (\id -> cotoId /= id) context.selection
        else
            cotoId :: context.selection
    }


clearCotonoma : Context -> Context
clearCotonoma context =
    { context | cotonoma = Nothing }


clearSelection : Context -> Context
clearSelection context =
    { context | selection = [] }


deleteSelection : CotoId -> Context -> Context
deleteSelection cotoId context =
    { context | selection = List.filter (\id -> cotoId /= id) context.selection }


setBeingDeselected : CotoId -> Context -> Context
setBeingDeselected cotoId context =
    { context
    | deselecting =
        context.deselecting |> Set.insert cotoId
    }


ctrlDown : Bool -> Context -> Context
ctrlDown down context =
    { context | ctrlDown = down }


type alias MemberConnCounts = Dict.Dict AmishiId Int
