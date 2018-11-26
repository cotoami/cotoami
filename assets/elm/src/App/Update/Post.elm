module App.Update.Post exposing (onPosted)

import App.Messages exposing (Msg)
import App.Types.Post exposing (Post)
import App.Submodels.Context exposing (Context)
import App.Submodels.LocalCotos exposing (LocalCotos)
import App.Update.Watch


onPosted :
    Context context
    -> Int
    -> Post
    -> LocalCotos model
    -> ( LocalCotos model, Cmd Msg )
onPosted context postId post model =
    model
        |> App.Submodels.LocalCotos.onPosted postId post
        |> App.Update.Watch.updateByPost context post
