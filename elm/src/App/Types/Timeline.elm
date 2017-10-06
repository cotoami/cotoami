module App.Types.Timeline exposing (..)

import Maybe exposing (andThen)
import App.Types.Coto exposing (Coto, CotoId, Cotonoma, CotonomaKey)
import App.Types.Post exposing (Post, defaultPost, toCoto, isSelfOrPostedIn)
import App.Types.Context exposing (Context)
import App.Types.Session


type alias Timeline =
    { editingNew : Bool
    , newContent : String
    , postIdCounter : Int
    , posts : List Post
    , loading : Bool
    }


defaultTimeline : Timeline
defaultTimeline =
    { editingNew = False
    , newContent = ""
    , postIdCounter = 0
    , posts = []
    , loading = False
    }


setEditingNew : Bool -> Timeline -> Timeline
setEditingNew editingNew timeline =
    { timeline | editingNew = editingNew }


getCoto : CotoId -> Timeline -> Maybe Coto
getCoto cotoId timeline =
    timeline.posts
        |> List.filter (\post -> post.cotoId == Just cotoId)
        |> List.head
        |> andThen toCoto


deleteCoto : Coto -> Timeline -> Timeline
deleteCoto coto timeline =
    { timeline
        | posts =
            List.filter
                (\post -> not (isSelfOrPostedIn coto post))
                timeline.posts
    }


setLoading : Timeline -> Timeline
setLoading timeline =
    { timeline | posts = [], loading = True }


updatePost : (Post -> Bool) -> (Post -> Post) -> Timeline -> Timeline
updatePost predicate update timeline =
    let
        posts =
            List.map
                (\post ->
                    if predicate post then
                        update post
                    else
                        post
                )
                timeline.posts
    in
        { timeline | posts = posts }


updateContent : CotoId -> String -> Timeline -> Timeline
updateContent cotoId content timeline =
    updatePost
        (\post -> post.cotoId == Just cotoId)
        (\post -> { post | content = content })
        timeline


setCotoSaved : Post -> Timeline -> Timeline
setCotoSaved apiResponse timeline =
    updatePost
        (\post -> post.postId == apiResponse.postId)
        (\post ->
            { post
                | cotoId = apiResponse.cotoId
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


postContent : Context -> Bool -> String -> Timeline -> ( Timeline, Post )
postContent context asCotonoma content timeline =
    let
        postId =
            timeline.postIdCounter + 1
    in
        { defaultPost
            | postId = Just postId
            , content = content
            , amishi = Maybe.map App.Types.Session.toAmishi context.session
            , asCotonoma = asCotonoma
            , postedIn = context.cotonoma
        }
            |> \newPost ->
                ( { timeline
                    | posts = newPost :: timeline.posts
                    , postIdCounter = postId
                    , newContent = ""
                  }
                , newPost
                )
