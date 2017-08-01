module Components.Timeline.Model exposing (..)

import Maybe exposing (andThen)
import App.Types.Coto exposing (Coto, CotoId, Cotonoma, CotonomaKey)
import App.Types.Post exposing (Post, toCoto, isSelfOrPostedIn)


type alias Model =
    { editingNew : Bool
    , newContent : String
    , postIdCounter : Int
    , posts : List Post
    , loading : Bool
    }


initModel : Model
initModel =
    { editingNew = False
    , newContent = ""
    , postIdCounter = 0
    , posts = []
    , loading = True
    }


getCoto : CotoId -> Model -> Maybe Coto
getCoto cotoId model =
    model.posts
        |> List.filter (\post -> post.cotoId == Just cotoId)
        |> List.head
        |> andThen toCoto


deleteCoto : Coto -> Model -> Model
deleteCoto coto model =
    { model
    | posts = model.posts |>
        List.filter (\post -> not (isSelfOrPostedIn coto post))
    }


setLoading : Model -> Model
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
