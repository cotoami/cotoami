module App.Types.Timeline exposing
    ( Timeline
    , addPost
    , cotoIds
    , cotonomatize
    , defaultTimeline
    , deleteCoto
    , deletePendingPost
    , getCoto
    , isEmpty
    , isScrolledToLatest
    , latestPost
    , nextPageIndex
    , post
    , setBeingDeleted
    , setInitializing
    , setLoading
    , setLoadingMore
    , setPaginatedPosts
    , setPostSaved
    , setPosts
    , setScrollPos
    , setScrollPosInitialized
    , updateCoto
    )

import App.Server.Pagination exposing (PaginatedList)
import App.Submodels.Context exposing (Context)
import App.Types.Coto exposing (Coto, CotoContent, CotoId, Cotonoma, CotonomaKey)
import App.Types.Post exposing (Post)
import Exts.Maybe exposing (isJust)
import Maybe
import Utils.EventUtil exposing (ScrollPos)


type alias Timeline =
    { posts : List Post
    , loading : Bool
    , initializingScrollPos : Bool
    , pageIndex : Int
    , more : Bool
    , loadingMore : Bool
    , postIdCounter : Int
    , scrollPos : Maybe ScrollPos
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
    , scrollPos = Nothing
    }


cotoIds : Timeline -> List CotoId
cotoIds timeline =
    timeline.posts
        |> List.map (\post -> [ post.cotoId, Maybe.map .id post.repost ])
        |> List.concat
        |> List.filterMap identity


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


setScrollPos : ScrollPos -> Timeline -> Timeline
setScrollPos scrollPos timeline =
    { timeline | scrollPos = Just scrollPos }


isScrolledToLatest : Timeline -> Bool
isScrolledToLatest timeline =
    timeline.scrollPos
        |> Maybe.map Utils.EventUtil.fromBottom
        |> Maybe.map (\scrollPosFromBottom -> scrollPosFromBottom < 60)
        |> Maybe.withDefault False


updateByPredicate : (Post -> Bool) -> (Post -> Post) -> Timeline -> Timeline
updateByPredicate predicate update timeline =
    timeline.posts
        |> List.map
            (\post ->
                if predicate post then
                    update post

                else
                    post
            )
        |> (\posts -> { timeline | posts = posts })


updateByCotoId : CotoId -> (Post -> Post) -> (Coto -> Coto) -> Timeline -> Timeline
updateByCotoId cotoId updatePost updateCoto timeline =
    updateByPredicate
        (\post -> App.Types.Post.getOriginalCotoId post == Just cotoId)
        (\post ->
            post.repost
                |> Maybe.map (\repost -> { post | repost = Just (updateCoto repost) })
                |> Maybe.withDefault (updatePost post)
        )
        timeline


updateCoto : Coto -> Timeline -> Timeline
updateCoto coto timeline =
    updateByCotoId
        coto.id
        (\post ->
            { post
                | content = coto.content
                , summary = coto.summary
                , asCotonoma = coto.asCotonoma
                , repostedIn = coto.repostedIn
            }
        )
        (\_ -> coto)
        timeline


cotonomatize : Cotonoma -> CotoId -> Timeline -> Timeline
cotonomatize cotonoma cotoId timeline =
    updateByCotoId
        cotoId
        (\post ->
            { post
                | isCotonoma = True
                , asCotonoma = Just cotonoma
            }
        )
        (\coto ->
            { coto | asCotonoma = Just cotonoma }
        )
        timeline


setPostSaved : Int -> Post -> Timeline -> Timeline
setPostSaved postId apiResponse timeline =
    updateByPredicate
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
    updateByPredicate
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
