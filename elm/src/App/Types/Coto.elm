module App.Types.Coto exposing (..)

import Date exposing (Date)
import Exts.Maybe exposing (isJust, isNothing)
import App.Types.Amishi exposing (Amishi)
import Util.StringUtil exposing (isBlank)


type alias ElementId =
    String


type alias CotoId =
    String


type alias CotonomaKey =
    String


type alias Coto =
    { id : CotoId
    , content : String
    , amishi : Maybe Amishi
    , postedIn : Maybe Cotonoma
    , asCotonoma : Bool
    , cotonomaKey : Maybe CotonomaKey
    , cotonomaPinned : Bool
    }


updateContent : String -> Coto -> Coto
updateContent content coto =
    { coto | content = content }


type alias Cotonoma =
    { id : String
    , key : CotonomaKey
    , name : String
    , pinned : Bool
    , cotoId : CotoId
    , owner : Maybe Amishi
    , updatedAt : Date
    }


toCoto : Cotonoma -> Coto
toCoto cotonoma =
    Coto
        cotonoma.cotoId
        cotonoma.name
        cotonoma.owner
        Nothing
        True
        (Just cotonoma.key)
        cotonoma.pinned


cotonomaNameMaxlength : Int
cotonomaNameMaxlength =
    30


validateCotonomaName : String -> Bool
validateCotonomaName string =
    not (isBlank string) && (String.length string) <= cotonomaNameMaxlength


isPostedInCotonoma : Maybe Cotonoma -> Coto -> Bool
isPostedInCotonoma maybeCotonoma coto =
    case maybeCotonoma of
        Nothing ->
            isNothing coto.postedIn

        Just cotonoma ->
            case coto.postedIn of
                Nothing ->
                    False

                Just postedIn ->
                    postedIn.id == cotonoma.id
