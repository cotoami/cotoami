module App.Types.Coto exposing (..)

import Exts.Maybe exposing (isNothing)
import App.Types.Amishi exposing (Amishi)


type alias CotoId = String


type alias CotonomaKey = String


type alias Coto =
    { id : CotoId
    , content : String
    , postedIn : Maybe Cotonoma
    , asCotonoma : Bool
    , cotonomaKey : Maybe CotonomaKey
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
