module App.Types.Post exposing
    ( Post
    , defaultPost
    , getCotoFromPosts
    , toCoto
    )

import App.Types.Amishi exposing (Amishi)
import App.Types.Coto exposing (Coto, CotoId, Cotonoma, CotonomaKey)
import Date exposing (Date)
import Utils.ListUtil



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
    , repost : Maybe Coto
    , repostedIn : List Cotonoma
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
    , repost = Nothing
    , repostedIn = []
    , beingDeleted = False
    }


toCoto : Post -> Maybe Coto
toCoto post =
    post.repost
        |> Maybe.map Just
        |> Maybe.withDefault
            (Maybe.map2
                (\cotoId postedAt ->
                    { id = cotoId
                    , content = post.content
                    , summary = post.summary
                    , amishi = post.amishi
                    , postedIn = post.postedIn
                    , postedAt = postedAt
                    , asCotonoma = post.asCotonoma
                    , repostedIn = post.repostedIn
                    , incomings = Nothing
                    , outgoings = Nothing
                    }
                )
                post.cotoId
                post.postedAt
            )


getCotoFromPosts : CotoId -> List Post -> Maybe Coto
getCotoFromPosts cotoId posts =
    Utils.ListUtil.findValue
        (\post ->
            toCoto post
                |> Maybe.map
                    (\coto ->
                        if coto.id == cotoId then
                            Just coto

                        else
                            Nothing
                    )
                |> Maybe.withDefault Nothing
        )
        posts
