module App.Types.Coto exposing
    ( Coto
    , CotoContent
    , CotoId
    , Cotonoma
    , CotonomaHolder
    , CotonomaKey
    , CotonomaStats
    , ElementId
    , addIncomings
    , addOutgoings
    , checkWritePermission
    , cotonomaNameMaxlength
    , decrementIncoming
    , decrementOutgoing
    , defaultCoto
    , getCotoFromCotonomaHolders
    , incrementIncoming
    , incrementOutgoing
    , postedInAnyCotonoma
    , removeFromList
    , replaceInList
    , revisedBefore
    , summaryMaxlength
    , toCoto
    , toTopic
    , updateContent
    , updateCotonomaInHolders
    , updateInList
    , validateCotonomaName
    )

import App.Markdown
import App.Types.Amishi exposing (Amishi)
import App.Types.Session exposing (Session)
import Date exposing (Date)
import Exts.Maybe exposing (isJust)
import Time exposing (Time)
import Utils.StringUtil exposing (isBlank)


type alias ElementId =
    String


type alias CotoId =
    String


type alias CotonomaKey =
    String


type alias Coto =
    { id : CotoId
    , content : String
    , summary : Maybe String
    , amishi : Maybe Amishi
    , postedIn : Maybe Cotonoma
    , postedAt : Date
    , asCotonoma : Maybe Cotonoma
    , repostedIn : List Cotonoma
    , incomings : Maybe Int
    , outgoings : Maybe Int
    }


defaultCoto : Coto
defaultCoto =
    { id = ""
    , content = ""
    , summary = Nothing
    , amishi = Nothing
    , postedIn = Nothing
    , postedAt = Date.fromTime 0
    , asCotonoma = Nothing
    , repostedIn = []
    , incomings = Nothing
    , outgoings = Nothing
    }


type alias CotoContent =
    { content : String
    , summary : Maybe String
    }


summaryMaxlength : Int
summaryMaxlength =
    200


updateContent : String -> Coto -> Coto
updateContent content coto =
    { coto | content = content }


incrementIncoming : Coto -> Coto
incrementIncoming =
    addIncomings 1


decrementIncoming : Coto -> Coto
decrementIncoming =
    addIncomings -1


addIncomings : Int -> Coto -> Coto
addIncomings diff coto =
    { coto
        | incomings =
            coto.incomings
                |> Maybe.map ((+) diff)
                |> Maybe.withDefault (max 0 diff)
                |> Just
    }


incrementOutgoing : Coto -> Coto
incrementOutgoing =
    addOutgoings 1


decrementOutgoing : Coto -> Coto
decrementOutgoing =
    addOutgoings -1


addOutgoings : Int -> Coto -> Coto
addOutgoings diff coto =
    { coto
        | outgoings =
            coto.outgoings
                |> Maybe.map ((+) diff)
                |> Maybe.withDefault (max 0 diff)
                |> Just
    }


checkWritePermission : Session -> { r | amishi : Maybe Amishi } -> Bool
checkWritePermission session coto =
    Maybe.map .id coto.amishi == Just session.amishi.id


toTopic : Coto -> Maybe String
toTopic coto =
    if isJust coto.asCotonoma then
        Just coto.content

    else
        case coto.summary of
            Just summary ->
                if String.length summary <= cotonomaNameMaxlength then
                    Just summary

                else
                    Nothing

            Nothing ->
                let
                    trimmedContent =
                        coto.content |> String.trim

                    textInEachBlock =
                        App.Markdown.extractTextFromMarkdown trimmedContent

                    firstLine =
                        textInEachBlock
                            |> List.head
                            |> Maybe.withDefault ""
                in
                if
                    not (String.contains "\n" trimmedContent)
                        && (List.length textInEachBlock == 1)
                        && (firstLine /= "")
                        && (String.length firstLine <= cotonomaNameMaxlength)
                then
                    Just firstLine

                else
                    Nothing


replaceInList : Coto -> List Coto -> List Coto
replaceInList replacement list =
    List.map
        (\coto ->
            if coto.id == replacement.id then
                replacement

            else
                coto
        )
        list


updateInList : CotoId -> (Coto -> Coto) -> List Coto -> List Coto
updateInList cotoId update list =
    List.map
        (\coto ->
            if coto.id == cotoId then
                update coto

            else
                coto
        )
        list


removeFromList : CotoId -> List Coto -> List Coto
removeFromList cotoId list =
    List.filter (\coto -> coto.id /= cotoId) list


type alias Cotonoma =
    { id : String
    , key : CotonomaKey
    , name : String
    , shared : Bool
    , cotoId : CotoId
    , owner : Maybe Amishi
    , postedAt : Date
    , updatedAt : Date
    , timelineRevision : Int
    , graphRevision : Int
    , lastPostTimestamp : Maybe Time
    }


type alias CotonomaHolder =
    { cotonoma : Cotonoma
    , postedIn : Maybe Cotonoma
    , repostedIn : List Cotonoma
    }


toCoto : CotonomaHolder -> Coto
toCoto { cotonoma, postedIn, repostedIn } =
    { id = cotonoma.cotoId
    , content = cotonoma.name
    , summary = Nothing
    , amishi = cotonoma.owner
    , postedIn = postedIn
    , postedAt = cotonoma.postedAt
    , asCotonoma = Just cotonoma
    , repostedIn = repostedIn
    , incomings = Nothing
    , outgoings = Nothing
    }


cotonomaNameMaxlength : Int
cotonomaNameMaxlength =
    50


validateCotonomaName : String -> Bool
validateCotonomaName string =
    not (isBlank string) && String.length string <= cotonomaNameMaxlength


revisedBefore : Cotonoma -> Bool
revisedBefore cotonoma =
    (cotonoma.timelineRevision > 0) || (cotonoma.graphRevision > 0)


getCotoFromCotonomaHolders : CotoId -> List CotonomaHolder -> Maybe Coto
getCotoFromCotonomaHolders cotoId holders =
    holders
        |> List.filter (\holder -> holder.cotonoma.cotoId == cotoId)
        |> List.head
        |> Maybe.map toCoto


updateCotonomaInHolders : Cotonoma -> List CotonomaHolder -> List CotonomaHolder
updateCotonomaInHolders cotonoma holders =
    List.map
        (\holder ->
            if holder.cotonoma.id == cotonoma.id then
                { holder | cotonoma = cotonoma }

            else
                holder
        )
        holders


type alias CotonomaStats =
    { key : CotonomaKey
    , cotos : Int
    , connections : Int
    }


type alias CotonomaPostable postable =
    { postable
        | postedIn : Maybe Cotonoma
        , repostedIn : List Cotonoma
    }


postedInAnyCotonoma : CotonomaPostable postable -> Bool
postedInAnyCotonoma postable =
    isJust postable.postedIn || not (List.isEmpty postable.repostedIn)
