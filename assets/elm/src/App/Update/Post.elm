module App.Update.Post exposing (onPosted, post)

import App.Commands
import App.Messages exposing (Msg)
import App.Server.Post
import App.Submodels.Context exposing (Context)
import App.Submodels.LocalCotos exposing (LocalCotos)
import App.Types.Coto exposing (CotoContent)
import App.Types.Post exposing (Post)
import App.Types.Timeline
import App.Update.Watch
import App.Views.FlowMsg


post : Context context -> CotoContent -> LocalCotos model -> ( LocalCotos model, Cmd Msg )
post context content model =
    let
        ( newTimeline, newPost ) =
            App.Types.Timeline.post context False content model.timeline
    in
    ( { model | timeline = newTimeline }
    , Cmd.batch
        [ App.Commands.scrollTimelineToBottom (\_ -> App.Messages.NoOp)
        , App.Server.Post.post
            context.clientId
            context.cotonoma
            (App.Messages.FlowMsg << App.Views.FlowMsg.Posted newTimeline.postIdCounter)
            newPost
        ]
    )


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
