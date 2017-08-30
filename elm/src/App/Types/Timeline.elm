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
getCoto cotoId model =
    model.posts
        |> List.filter (\post -> post.cotoId == Just cotoId)
        |> List.head
        |> andThen toCoto


deleteCoto : Coto -> Timeline -> Timeline
deleteCoto coto model =
    { model
    | posts = model.posts |>
        List.filter (\post -> not (isSelfOrPostedIn coto post))
    }


setLoading : Timeline -> Timeline
setLoading model =
    { model | posts = [], loading = True }


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


postContent : String -> Maybe Cotonoma -> Bool -> String -> Timeline -> ( Timeline, Post )
postContent clientId maybeCotonoma asCotonoma content model =
    let
        postId = model.postIdCounter + 1
    in
        { defaultPost
        | postId = Just postId
        , content = content
        , asCotonoma = asCotonoma
        , postedIn = maybeCotonoma
        }
            |> \newPost ->
                ( { model
                  | posts = newPost :: model.posts
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
