module App.Types.Timeline exposing (..)

import Maybe exposing (andThen)
import App.Types.Coto exposing (Coto, CotoId, Cotonoma, CotonomaKey)
import App.Types.Post exposing (Post, defaultPost, toCoto, isSelfOrPostedIn)


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
    , loading = True
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


updatePost : (Post -> Post) -> CotoId -> List Post -> List Post
updatePost update cotoId posts =
    List.map
        (\post ->
            if post.cotoId == Just cotoId then
                update post
            else
                post
        )
        posts


updateContent : CotoId -> String -> Timeline -> Timeline
updateContent cotoId content timeline =
    { timeline
        | posts =
            updatePost
                (\post -> { post | content = content })
                cotoId
                timeline.posts
    }


postContent : String -> Maybe Cotonoma -> Bool -> String -> Timeline -> ( Timeline, Post )
postContent clientId maybeCotonoma asCotonoma content timeline =
    let
        postId =
            timeline.postIdCounter + 1
    in
        { defaultPost
            | postId = Just postId
            , content = content
            , asCotonoma = asCotonoma
            , postedIn = maybeCotonoma
        }
            |> \newPost ->
                ( { timeline
                    | posts = newPost :: timeline.posts
                    , postIdCounter = postId
                    , newContent = ""
                  }
                , newPost
                )


setCotoSaved : Post -> Timeline -> Timeline
setCotoSaved apiResponse timeline =
    { timeline
        | posts = App.Types.Post.setCotoSaved apiResponse timeline.posts
    }


setBeingDeleted : Coto -> Timeline -> Timeline
setBeingDeleted coto timeline =
    { timeline
        | posts =
            List.map
                (\post ->
                    if isSelfOrPostedIn coto post then
                        { post | beingDeleted = True }
                    else
                        post
                )
                timeline.posts
    }
