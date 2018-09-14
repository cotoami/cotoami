module App.Types.Timeline
    exposing
        ( Timeline
        , defaultTimeline
        , setScrollPosInitialized
        , isEmpty
        , addPost
        , setPaginatedPosts
        , nextPageIndex
        , getCoto
        , deleteCoto
        , deletePendingPost
        , setLoading
        , setLoadingMore
        , updatePost
        , cotonomatize
        , setCotoSaved
        , setBeingDeleted
        , post
        )

import Maybe
import Exts.Maybe exposing (isJust)
import App.Types.Coto exposing (Coto, CotoContent, CotoId, Cotonoma, CotonomaKey)
import App.Types.Post exposing (Post, PaginatedPosts)
import App.Types.Session
import App.Submodels.Context exposing (Context)


type alias Timeline =
    { posts : List Post
    , loading : Bool
    , initializingScrollPos : Bool
    , pageIndex : Int
    , more : Bool
    , loadingMore : Bool
    , postIdCounter : Int
    }


defaultTimeline : Timeline
defaultTimeline =
    { posts = []
    , loading = False
    , initializingScrollPos = False
    , pageIndex = 0
    , more = False
    , loadingMore = False
    , postIdCounter = 0
    }


setScrollPosInitialized : Timeline -> Timeline
setScrollPosInitialized timeline =
    { timeline | initializingScrollPos = False }


isEmpty : Timeline -> Bool
isEmpty timeline =
    List.isEmpty timeline.posts


addPost : Post -> Timeline -> Timeline
addPost post timeline =
    { timeline | posts = post :: timeline.posts }


setPaginatedPosts : PaginatedPosts -> Timeline -> Timeline
setPaginatedPosts paginatedPosts timeline =
    { timeline
        | posts =
            if paginatedPosts.pageIndex == 0 then
                paginatedPosts.posts
            else
                timeline.posts ++ paginatedPosts.posts
        , pageIndex = paginatedPosts.pageIndex
        , more = paginatedPosts.totalPages > (paginatedPosts.pageIndex + 1)
        , loading = False
        , loadingMore = False
    }


nextPageIndex : Timeline -> Int
nextPageIndex timeline =
    timeline.pageIndex + 1


getCoto : CotoId -> Timeline -> Maybe Coto
getCoto cotoId timeline =
    App.Types.Post.getCotoFromPosts cotoId timeline.posts


deleteCoto : Coto -> Timeline -> Timeline
deleteCoto coto timeline =
    timeline.posts
        |> List.filter (\post -> not (App.Types.Post.isSelfOrPostedIn coto post))
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


setLoadingMore : Timeline -> Timeline
setLoadingMore timeline =
    { timeline | loadingMore = True }


updatePost_ : (Post -> Bool) -> (Post -> Post) -> Timeline -> Timeline
updatePost_ predicate update timeline =
    timeline.posts
        |> List.map
            (\post ->
                if predicate post then
                    update post
                else
                    post
            )
        |> (\posts -> { timeline | posts = posts })


updatePost : Coto -> Timeline -> Timeline
updatePost coto timeline =
    updatePost_
        (\post -> post.cotoId == Just coto.id)
        (\post ->
            { post
                | content = coto.content
                , summary = coto.summary
                , asCotonoma = coto.asCotonoma
            }
        )
        timeline


cotonomatize : Cotonoma -> CotoId -> Timeline -> Timeline
cotonomatize cotonoma cotoId timeline =
    updatePost_
        (\post -> post.cotoId == Just cotoId)
        (\post ->
            { post
                | isCotonoma = True
                , asCotonoma = Just cotonoma
            }
        )
        timeline


setCotoSaved : Int -> Post -> Timeline -> Timeline
setCotoSaved postId apiResponse timeline =
    updatePost_
        (\post -> post.postId == Just postId)
        (\post ->
            { post
                | postId = Just postId
                , cotoId = apiResponse.cotoId
                , postedAt = apiResponse.postedAt
                , asCotonoma = apiResponse.asCotonoma
            }
        )
        timeline


setBeingDeleted : Coto -> Timeline -> Timeline
setBeingDeleted coto timeline =
    updatePost_
        (\post -> App.Types.Post.isSelfOrPostedIn coto post)
        (\post -> { post | beingDeleted = True })
        timeline


post : Context context -> Bool -> CotoContent -> Timeline -> ( Timeline, Post )
post context isCotonoma content timeline =
    let
        defaultPost =
            App.Types.Post.defaultPost

        postId =
            timeline.postIdCounter + 1

        newPost =
            { defaultPost
                | postId = Just postId
                , content = content.content
                , summary = content.summary
                , amishi = Maybe.map App.Types.Session.toAmishi context.session
                , isCotonoma = isCotonoma
                , postedIn = context.cotonoma
            }
    in
        ( { timeline
            | posts = newPost :: timeline.posts
            , postIdCounter = postId
          }
        , newPost
        )
