module App.Types.Coto exposing (..)

import Json.Decode as Decode
import Exts.Maybe exposing (isNothing)
import App.Types.Amishi exposing (Amishi, decodeAmishi)


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
