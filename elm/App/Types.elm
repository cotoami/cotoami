module App.Types exposing (..)

import Dict
import Json.Decode as Decode
        
        
type Route
    = HomeRoute
    | CotonomaRoute CotonomaKey
    | NotFoundRoute
            

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


type alias CotonomaKey = String


type alias Coto =
    { id : Int
    , content : String
    , postedIn : Maybe Cotonoma
    , asCotonoma : Bool
    , cotonomaKey : CotonomaKey
    }


type alias Cotonoma =
    { id : Int
    , key : CotonomaKey
    , name : String
    , cotoId : Int
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


type alias CotoSelection = List Int


updateCotoSelection : Int -> CotoSelection -> CotoSelection
updateCotoSelection cotoId selection =
    if selection |> List.member cotoId  then
        List.filter (\id -> cotoId /= id) selection
    else
        cotoId :: selection


type alias Connection =
    { key : String
    , end : Int
    }
    
    
newConnection : Maybe Int -> Int -> Connection
newConnection maybeStart end =
    let
        startLabel =
            case maybeStart of
                Nothing -> "root"
                Just start -> toString start
        endLabel = toString end
    in
        Connection 
            ("connection-" ++ startLabel ++ "-" ++ endLabel)
            end


type alias MemberConnCounts = Dict.Dict Int Int
