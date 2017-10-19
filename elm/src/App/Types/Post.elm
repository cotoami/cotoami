module App.Types.Post exposing (..)

import Date exposing (Date)
import Exts.Maybe exposing (isNothing)
import App.Types.Amishi exposing (Amishi)
import App.Types.Coto exposing (Coto, CotoId, Cotonoma, CotonomaKey)


-- https://twitter.com/marubinotto/status/827743441090072577


type alias Post =
    { postId : Maybe Int
    , cotoId : Maybe CotoId
    , content : String
    , amishi : Maybe Amishi
    , postedIn : Maybe Cotonoma
    , postedAt : Maybe Date
    , asCotonoma : Bool
    , cotonomaKey : Maybe CotonomaKey
    , beingDeleted : Bool
    }


defaultPost : Post
defaultPost =
    { postId = Nothing
    , cotoId = Nothing
    , content = ""
    , amishi = Nothing
    , postedIn = Nothing
    , postedAt = Nothing
    , asCotonoma = False
    , cotonomaKey = Nothing
    , beingDeleted = False
    }


toCoto : Post -> Maybe Coto
toCoto post =
    Maybe.map2
        (\cotoId postedAt ->
            Coto
                cotoId
                post.content
                post.amishi
                post.postedIn
                postedAt
                post.asCotonoma
                post.cotonomaKey
        )
        post.cotoId
        post.postedAt


isPostedInCotonoma : Maybe Cotonoma -> Post -> Bool
isPostedInCotonoma maybeCotonoma post =
    case maybeCotonoma of
        Nothing ->
            isNothing post.postedIn

        Just cotonoma ->
            case post.postedIn of
                Nothing ->
                    False

                Just postedIn ->
                    postedIn.id == cotonoma.id


isPostedInCoto : Coto -> Post -> Bool
isPostedInCoto coto post =
    if coto.asCotonoma then
        case post.postedIn of
            Nothing ->
                False

            Just postedIn ->
                (Just postedIn.key) == coto.cotonomaKey
    else
        False


isSelfOrPostedIn : Coto -> Post -> Bool
isSelfOrPostedIn coto post =
    post.cotoId == Just coto.id || (isPostedInCoto coto post)
