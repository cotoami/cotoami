module App.Types.Timeline exposing
    ( Timeline
    , addPost
    , cotonomatize
    , defaultTimeline
    , deleteCoto
    , deletePendingPost
    , getCoto
    , isEmpty
    , latestPost
    , nextPageIndex
    , post
    , setBeingDeleted
    , setCotoSaved
    , setInitializing
    , setLoading
    , setLoadingMore
    , setPaginatedPosts
    , setPosts
    , setScrollPosInitialized
    , updatePost
    )

import App.Server.Pagination exposing (PaginatedList)
import App.Submodels.Context exposing (Context)
import App.Types.Coto exposing (Coto, CotoContent, CotoId, Cotonoma, CotonomaKey)
import App.Types.Post exposing (Post)
import Exts.Maybe exposing (isJust)
import Maybe


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


setPosts : List Post -> Timeline -> Timeline
setPosts posts timeline =
    { timeline
        | posts = posts
        , pageIndex = 0
        , more = False
        , loading = False
        , loadingMore = False
    }


setPaginatedPosts : PaginatedList Post -> Timeline -> Timeline
setPaginatedPosts paginatedPosts timeline =
    { timeline
        | posts =
            if paginatedPosts.pageIndex == 0 then
                paginatedPosts.list

            else
                timeline.posts ++ paginatedPosts.list
        , pageIndex = paginatedPosts.pageIndex
        , more = paginatedPosts.totalPages > (paginatedPosts.pageIndex + 1)
        , loading = False
        , loadingMore = False
    }


nextPageIndex : Timeline -> Int
nextPageIndex timeline =
    timeline.pageIndex + 1


latestPost : Timeline -> Maybe Post
latestPost timeline =
    List.head timeline.posts


getCoto : CotoId -> Timeline -> Maybe Coto
getCoto cotoId timeline =
    App.Types.Post.getCotoFromPosts cotoId timeline.posts


deleteCoto : CotoId -> Timeline -> Timeline
deleteCoto cotoId timeline =
    timeline.posts
        |> List.filter (\post -> post.cotoId /= Just cotoId)
        |> (\posts -> { timeline | posts = posts })


deletePendingPost : Int -> Timeline -> Timeline
deletePendingPost postId timeline =
    timeline.posts
        |> List.filter
            (\post -> isJust post.cotoId || post.postId /= Just postId)
        |> (\posts -> { timeline | posts = posts })


setInitializing : Timeline -> Timeline
setInitializing timeline =
    { timeline
        | posts = []
        , loading = True
        , initializingScrollPos = True
    }


setLoading : Timeline -> Timeline
setLoading timeline =
    { timeline | loading = True }


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


setBeingDeleted : CotoId -> Timeline -> Timeline
setBeingDeleted cotoId timeline =
    updatePost_
        (\post -> post.cotoId == Just cotoId)
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
                , amishi = Maybe.map .amishi context.session
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
