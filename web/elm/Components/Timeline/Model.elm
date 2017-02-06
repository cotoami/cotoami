module Components.Timeline.Model exposing (..)

import Json.Decode as Decode
import Exts.Maybe exposing (isNothing)
import App.Types exposing (Coto, Cotonoma, decodeCotonoma)


-- https://twitter.com/marubinotto/status/827743441090072577
type alias Post =
    { postId : Maybe Int
    , cotoId : Maybe Int
    , content : String
    , postedIn : Maybe Cotonoma
    , asCotonoma : Bool
    , cotonomaKey : String
    , beingDeleted : Bool
    }


defaultPost : Post
defaultPost =
    { postId = Nothing 
    , cotoId = Nothing
    , content = ""
    , postedIn = Nothing
    , asCotonoma = False
    , cotonomaKey = ""
    , beingDeleted = False
    }


decodePost : Decode.Decoder Post
decodePost =
    Decode.map7 Post
        (Decode.maybe (Decode.field "postId" Decode.int))
        (Decode.maybe (Decode.field "id" Decode.int))
        (Decode.field "content" Decode.string)
        (Decode.maybe (Decode.field "posted_in" decodeCotonoma))
        (Decode.field "as_cotonoma" Decode.bool)
        (Decode.field "cotonoma_key" Decode.string)
        (Decode.succeed False)


toCoto : Post -> Maybe Coto
toCoto post =
    case post.cotoId of
        Nothing -> 
            Nothing
        Just cotoId -> 
            Just 
                (Coto 
                    cotoId 
                    post.content 
                    post.postedIn 
                    post.asCotonoma 
                    post.cotonomaKey
                )


isPostedInCotonoma : Maybe Cotonoma -> Post -> Bool
isPostedInCotonoma maybeCotonoma post =
    case maybeCotonoma of
        Nothing -> isNothing post.postedIn
        Just cotonoma -> 
            case post.postedIn of
                Nothing -> False
                Just postedIn -> postedIn.id == cotonoma.id


isPostedInCoto : Coto -> Post -> Bool
isPostedInCoto coto post =
    if coto.asCotonoma then
        case post.postedIn of
            Nothing -> False
            Just postedIn -> postedIn.key == coto.cotonomaKey
    else
        False
        

isSelfOrPostedIn : Coto -> Post -> Bool
isSelfOrPostedIn coto post =
    post.cotoId == Just coto.id || (isPostedInCoto coto post) 
    

type alias Model =
    { editingNew : Bool
    , newContent : String
    , postIdCounter : Int
    , posts : List Post
    }


initModel : Model
initModel =
    { editingNew = False
    , newContent = ""
    , postIdCounter = 0
    , posts = []
    }


updatePost : (Post -> Post) -> Int -> List Post -> List Post
updatePost update cotoId posts =
     List.map 
         (\post -> 
             if post.cotoId == Just cotoId then
                 update post
             else
                 post
         )
         posts        
