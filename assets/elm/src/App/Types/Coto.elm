module App.Types.Coto
    exposing
        ( ElementId
        , CotoId
        , CotoSelection
        , CotonomaKey
        , Coto
        , CotoContent
        , summaryMaxlength
        , updateContent
        , checkWritePermission
        , toTopic
        , Cotonoma
        , toCoto
        , cotonomaNameMaxlength
        , validateCotonomaName
        , revisedBefore
        , CotonomaStats
        )

import Date exposing (Date)
import Time exposing (Time)
import Exts.Maybe exposing (isJust)
import App.Markdown
import App.Types.Amishi exposing (Amishi)
import App.Types.Session exposing (Session)
import Utils.StringUtil exposing (isBlank)


type alias ElementId =
    String


type alias CotoId =
    String


type alias CotoSelection =
    List CotoId


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


checkWritePermission : Session -> { r | amishi : Maybe Amishi } -> Bool
checkWritePermission session coto =
    (Maybe.map (.id) coto.amishi) == (Just session.amishi.id)


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
                        (not (String.contains "\n" trimmedContent))
                            && (List.length textInEachBlock == 1)
                            && (firstLine /= "")
                            && (String.length firstLine <= cotonomaNameMaxlength)
                    then
                        Just firstLine
                    else
                        Nothing


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


toCoto : Cotonoma -> Coto
toCoto cotonoma =
    Coto
        cotonoma.cotoId
        cotonoma.name
        Nothing
        cotonoma.owner
        Nothing
        cotonoma.postedAt
        (Just cotonoma)


cotonomaNameMaxlength : Int
cotonomaNameMaxlength =
    50


validateCotonomaName : String -> Bool
validateCotonomaName string =
    not (isBlank string) && (String.length string) <= cotonomaNameMaxlength


revisedBefore : Cotonoma -> Bool
revisedBefore cotonoma =
    (cotonoma.timelineRevision > 0) || (cotonoma.graphRevision > 0)


type alias CotonomaStats =
    { key : CotonomaKey
    , cotos : Int
    , connections : Int
    }
