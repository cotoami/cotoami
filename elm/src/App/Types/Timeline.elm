module App.Types.Timeline exposing (..)

import Maybe
import Exts.Maybe exposing (isJust)
import App.Types.Coto exposing (Coto, CotoId, Cotonoma, CotonomaKey)
import App.Types.Post exposing (Post, defaultPost, toCoto, isSelfOrPostedIn)
import App.Types.Context exposing (Context)
import App.Types.Session


-- editorCounter: avoid unwanted cursor jump with onInput
-- https://github.com/elm-lang/html/issues/105#issuecomment-309524197


type alias Timeline =
    { editorOpen : Bool
    , newContent : String
    , editorCounter : Int
    , postIdCounter : Int
    , posts : List Post
    , loading : Bool
    , initializingScrollPos : Bool
    }


defaultTimeline : Timeline
defaultTimeline =
    { editorOpen = False
    , newContent = ""
    , editorCounter = 0
    , postIdCounter = 0
    , posts = []
    , loading = False
    , initializingScrollPos = False
    }


isEmpty : Timeline -> Bool
isEmpty timeline =
    List.isEmpty timeline.posts


openOrCloseEditor : Bool -> Timeline -> Timeline
openOrCloseEditor open timeline =
    { timeline | editorOpen = open }


setPosts : List Post -> Timeline -> Timeline
setPosts posts timeline =
    { timeline | posts = posts, loading = False }


getCoto : CotoId -> Timeline -> Maybe Coto
getCoto cotoId timeline =
    timeline.posts
        |> List.filter (\post -> post.cotoId == Just cotoId)
        |> List.head
        |> Maybe.andThen toCoto


deleteCoto : Coto -> Timeline -> Timeline
deleteCoto coto timeline =
    timeline.posts
        |> List.filter (\post -> not (isSelfOrPostedIn coto post))
        |> (\posts -> { timeline | posts = posts })


deletePendingPost : Int -> Timeline -> Timeline
deletePendingPost postId timeline =
    timeline.posts
        |> List.filter
            (\post -> (isJust post.cotoId) || post.postId /= (Just postId))
        |> (\posts -> { timeline | posts = posts })


setLoading : Timeline -> Timeline
setLoading timeline =
    { timeline
        | posts = []
        , loading = True
        , initializingScrollPos = True
    }


updatePost : (Post -> Bool) -> (Post -> Post) -> Timeline -> Timeline
updatePost predicate update timeline =
    timeline.posts
        |> List.map
            (\post ->
                if predicate post then
                    update post
                else
                    post
            )
        |> (\posts -> { timeline | posts = posts })


updateContent : Coto -> Timeline -> Timeline
updateContent coto timeline =
    updatePost
        (\post -> post.cotoId == Just coto.id)
        (\post ->
            { post
                | content = coto.content
                , summary = coto.summary
            }
        )
        timeline


cotonomatize : CotoId -> CotonomaKey -> Timeline -> Timeline
cotonomatize cotoId cotonomaKey timeline =
    updatePost
        (\post -> post.cotoId == Just cotoId)
        (\post ->
            { post
                | asCotonoma = True
                , cotonomaKey = Just cotonomaKey
            }
        )
        timeline


setCotoSaved : Int -> Post -> Timeline -> Timeline
setCotoSaved postId apiResponse timeline =
    updatePost
        (\post -> post.postId == Just postId)
        (\post ->
            { post
                | postId = Just postId
                , cotoId = apiResponse.cotoId
                , postedAt = apiResponse.postedAt
                , cotonomaKey = apiResponse.cotonomaKey
            }
        )
        timeline


setBeingDeleted : Coto -> Timeline -> Timeline
setBeingDeleted coto timeline =
    updatePost
        (\post -> isSelfOrPostedIn coto post)
        (\post -> { post | beingDeleted = True })
        timeline


post : Context -> Bool -> Maybe String -> String -> Timeline -> ( Timeline, Post )
post context asCotonoma summary content timeline =
    let
        postId =
            timeline.postIdCounter + 1
    in
        { defaultPost
            | postId = Just postId
            , content = content
            , summary = summary
            , amishi = Maybe.map App.Types.Session.toAmishi context.session
            , asCotonoma = asCotonoma
            , postedIn = context.cotonoma
        }
            |> \newPost ->
                ( { timeline
                    | posts = newPost :: timeline.posts
                    , postIdCounter = postId
                    , newContent = ""
                    , editorCounter = timeline.editorCounter + 1
                  }
                , newPost
                )
