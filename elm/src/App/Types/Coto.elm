module App.Types.Coto exposing (..)

import Exts.Maybe exposing (isJust, isNothing)
import App.Types.Amishi exposing (Amishi)


type alias CotoId = String


type alias CotonomaKey = String


type alias Coto =
    { id : CotoId
    , content : String
    , amishi : Maybe Amishi
    , postedIn : Maybe Cotonoma
    , asCotonoma : Bool
    , cotonomaKey : Maybe CotonomaKey
    }


initCoto : CotoId -> String -> Maybe Amishi -> Maybe Cotonoma -> Maybe CotonomaKey -> Coto
initCoto id content maybeAmishi maybePostedIn maybeCotonomaKey =
    { id = id
    , content = content
    , amishi = maybeAmishi
    , postedIn = maybePostedIn
    , asCotonoma = isJust maybeCotonomaKey
    , cotonomaKey = maybeCotonomaKey
    }


type alias Cotonoma =
    { id : String
    , key : CotonomaKey
    , name : String
    , cotoId : CotoId
    , owner : Maybe Amishi
    }


isPostedInCotonoma : Maybe Cotonoma -> Coto -> Bool
isPostedInCotonoma maybeCotonoma coto =
    case maybeCotonoma of
        Nothing ->
            isNothing coto.postedIn
        Just cotonoma ->
            case coto.postedIn of
                Nothing -> False
                Just postedIn -> postedIn.id == cotonoma.id
