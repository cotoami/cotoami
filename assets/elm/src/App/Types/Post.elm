module App.Types.Post exposing
    ( Post
    , defaultPost
    , getCotoFromPosts
    , toCoto
    )

import App.Types.Amishi exposing (Amishi)
import App.Types.Coto exposing (Coto, CotoId, Cotonoma, CotonomaKey)
import Date exposing (Date)



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
            { id = cotoId
            , content = post.content
            , summary = post.summary
            , amishi = post.amishi
            , postedIn = post.postedIn
            , postedAt = postedAt
            , asCotonoma = post.asCotonoma
            , incomings = Nothing
            , outgoings = Nothing
            }
        )
        post.cotoId
        post.postedAt


getCotoFromPosts : CotoId -> List Post -> Maybe Coto
getCotoFromPosts cotoId posts =
    posts
        |> List.filter (\post -> post.cotoId == Just cotoId)
        |> List.head
        |> Maybe.andThen toCoto
