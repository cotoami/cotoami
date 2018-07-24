module App.Types.Timeline exposing (..)

import Maybe
import Json.Decode as Decode
import Json.Encode as Encode
import Exts.Maybe exposing (isJust)
import App.Types.Coto exposing (Coto, CotoId, Cotonoma, CotonomaKey)
import App.Types.Post exposing (Post, PaginatedPosts)
import App.Types.Context exposing (Context)
import App.Types.Session


type TimelineView
    = StreamView
    | TileView


type alias Filter =
    { excludePinnedGraph : Bool
    , excludePostsInCotonoma : Bool
    }


defaultFilter : Filter
defaultFilter =
    { excludePinnedGraph = False
    , excludePostsInCotonoma = False
    }


decodeFilter : Decode.Decoder Filter
decodeFilter =
    Decode.map2 Filter
        (Decode.field "excludePinnedGraph" Decode.bool)
        (Decode.field "excludePostsInCotonoma" Decode.bool)


encodeFilter : Filter -> Encode.Value
encodeFilter filter =
    Encode.object
        [ ( "excludePinnedGraph", Encode.bool filter.excludePinnedGraph )
        , ( "excludePostsInCotonoma", Encode.bool filter.excludePostsInCotonoma )
        ]


type alias Timeline =
    { hidden : Bool
    , view : TimelineView
    , filter : Filter
    , editorOpen : Bool
    , newContent : String
    , editorCounter : Int
    , postIdCounter : Int
    , posts : List Post
    , loading : Bool
    , initializingScrollPos : Bool
    , pageIndex : Int
    , more : Bool
    , loadingMore : Bool
    }


defaultTimeline : Timeline
defaultTimeline =
    { hidden = False
    , view = StreamView
    , filter = defaultFilter
    , editorOpen = False
    , newContent = ""
    , editorCounter = 0
    , postIdCounter = 0
    , posts = []
    , loading = False
    , initializingScrollPos = False
    , pageIndex = 0
    , more = False
    , loadingMore = False
    }


toggle : Timeline -> Timeline
toggle timeline =
    { timeline | hidden = not timeline.hidden }


switchView : TimelineView -> Timeline -> Timeline
switchView view timeline =
    { timeline | view = view }


setFilter : Filter -> Timeline -> Timeline
setFilter filter timeline =
    { timeline | filter = filter }


setScrollPosInitialized : Timeline -> Timeline
setScrollPosInitialized timeline =
    { timeline | initializingScrollPos = False }


isEmpty : Timeline -> Bool
isEmpty timeline =
    List.isEmpty timeline.posts


openOrCloseEditor : Bool -> Timeline -> Timeline
openOrCloseEditor open timeline =
    { timeline | editorOpen = open }


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


cotonomatize : Cotonoma -> CotoId -> Timeline -> Timeline
cotonomatize cotonoma cotoId timeline =
    updatePost
        (\post -> post.cotoId == Just cotoId)
        (\post ->
            { post
                | asCotonoma = True
                , cotonoma = Just cotonoma
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
                , cotonoma = apiResponse.cotonoma
            }
        )
        timeline


setBeingDeleted : Coto -> Timeline -> Timeline
setBeingDeleted coto timeline =
    updatePost
        (\post -> App.Types.Post.isSelfOrPostedIn coto post)
        (\post -> { post | beingDeleted = True })
        timeline


post : Context -> Bool -> Maybe String -> String -> Timeline -> ( Timeline, Post )
post context asCotonoma summary content timeline =
    let
        defaultPost =
            App.Types.Post.defaultPost

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
