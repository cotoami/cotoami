module App.Types exposing (..)

import Dict
import Json.Decode as Decode
import Exts.Maybe exposing (isNothing)

        
type Route
    = HomeRoute
    | CotonomaRoute CotonomaKey
    | NotFoundRoute
    
    
type ViewInMobile
    = TimelineView
    | PinnedView
    | TraversalsView
            

type alias Amishi =
    { id : Int
    , email : String
    , avatarUrl : String
    , displayName : String
    }


decodeAmishi : Decode.Decoder Amishi
decodeAmishi =
    Decode.map4 Amishi
        (Decode.field "id" Decode.int)
        (Decode.field "email" Decode.string)
        (Decode.field "avatar_url" Decode.string)
        (Decode.field "display_name" Decode.string)


type alias Session =
    { token : String
    , websocketUrl : String
    , id : Int
    , email : String
    , avatarUrl : String
    , displayName : String
    }


decodeSession : Decode.Decoder Session
decodeSession =
    Decode.map6 Session
        (Decode.field "token" Decode.string)
        (Decode.field "websocket_url" Decode.string)
        (Decode.field "id" Decode.int)
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


type alias CotoId = Int


type alias CotonomaKey = String


type alias Coto =
    { id : CotoId
    , content : String
    , postedIn : Maybe Cotonoma
    , asCotonoma : Bool
    , cotonomaKey : CotonomaKey
    }


type alias Cotonoma =
    { id : Int
    , key : CotonomaKey
    , name : String
    , cotoId : CotoId
    , owner : Maybe Amishi
    }


decodeCotonoma : Decode.Decoder Cotonoma
decodeCotonoma =
    Decode.map5 Cotonoma
        (Decode.field "id" Decode.int)
        (Decode.field "key" Decode.string)
        (Decode.field "name" Decode.string)
        (Decode.field "coto_id" Decode.int)
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


updateCotoSelection : CotoId -> CotoSelection -> CotoSelection
updateCotoSelection cotoId selection =
    if selection |> List.member cotoId  then
        List.filter (\id -> cotoId /= id) selection
    else
        cotoId :: selection


type alias MemberConnCounts = Dict.Dict Int Int
