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
    , summary : Maybe String
    , amishi : Maybe Amishi
    , postedIn : Maybe Cotonoma
    , postedAt : Maybe Date
    , isCotonoma : Bool
    , asCotonoma : Maybe Cotonoma
    , beingDeleted : Bool
    }


defaultPost : Post
defaultPost =
    { postId = Nothing
    , cotoId = Nothing
    , content = ""
    , summary = Nothing
    , amishi = Nothing
    , postedIn = Nothing
    , postedAt = Nothing
    , isCotonoma = False
    , asCotonoma = Nothing
    , beingDeleted = False
    }


toCoto : Post -> Maybe Coto
toCoto post =
    Maybe.map2
        (\cotoId postedAt ->
            Coto
                cotoId
                post.content
                post.summary
                post.amishi
                post.postedIn
                postedAt
                post.asCotonoma
        )
        post.cotoId
        post.postedAt


isPostedInCotonoma : Maybe Cotonoma -> Post -> Bool
isPostedInCotonoma maybeCotonoma post =
    maybeCotonoma
        |> Maybe.map
            (\cotonoma ->
                post.postedIn
                    |> Maybe.map (\postedIn -> postedIn.id == cotonoma.id)
                    |> Maybe.withDefault False
            )
        |> Maybe.withDefault (isNothing post.postedIn)


isPostedInCoto : Coto -> Post -> Bool
isPostedInCoto coto post =
    coto.asCotonoma
        |> Maybe.map
            (\cotonoma ->
                post.postedIn
                    |> Maybe.map (\postedIn -> postedIn.key == cotonoma.key)
                    |> Maybe.withDefault False
            )
        |> Maybe.withDefault False


isSelfOrPostedIn : Coto -> Post -> Bool
isSelfOrPostedIn coto post =
    post.cotoId == Just coto.id || (isPostedInCoto coto post)


type alias PaginatedPosts =
    { posts : List Post
    , pageIndex : Int
    , totalPages : Int
    }


getCotoFromPosts : CotoId -> List Post -> Maybe Coto
getCotoFromPosts cotoId posts =
    posts
        |> List.filter (\post -> post.cotoId == Just cotoId)
        |> List.head
        |> Maybe.andThen toCoto
