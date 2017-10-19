module App.Types.Coto exposing (..)

import Date exposing (Date)
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


cotonomaNameMaxlength : Int
cotonomaNameMaxlength =
    30


validateCotonomaName : String -> Bool
validateCotonomaName string =
    not (isBlank string) && (String.length string) <= cotonomaNameMaxlength
