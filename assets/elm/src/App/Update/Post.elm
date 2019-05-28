module App.Update.Post exposing (post, scrollTimelineIfNeeded)

import App.Commands
import App.Messages exposing (Msg)
import App.Server.Post
import App.Submodels.Context exposing (Context)
import App.Submodels.LocalCotos exposing (LocalCotos)
import App.Types.Coto exposing (CotoContent)
import App.Types.Timeline
import App.Views.FlowMsg
import Utils.UpdateUtil exposing (..)


post : Context context -> CotoContent -> LocalCotos model -> ( LocalCotos model, Cmd Msg )
post context content model =
    let
        ( newTimeline, newPost ) =
            App.Types.Timeline.post context False content model.timeline
    in
    { model | timeline = newTimeline }
        |> withCmd
            (\_ ->
                App.Server.Post.post
                    context.clientId
                    context.cotonoma
                    (App.Messages.FlowMsg
                        << App.Views.FlowMsg.Posted
                            newTimeline.postIdCounter
                    )
                    newPost
            )
        |> addCmd scrollTimelineIfNeeded


scrollTimelineIfNeeded : LocalCotos model -> Cmd Msg
scrollTimelineIfNeeded model =
    if App.Types.Timeline.isScrolledToLatest model.timeline then
        App.Commands.scrollTimelineToBottom (\_ -> App.Messages.NoOp)

    else
        Cmd.none
