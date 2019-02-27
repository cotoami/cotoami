module App.Update.Watch exposing
    ( clearUnread
    , updateByPost
    )

import App.Messages exposing (Msg(WatchTimestampUpdated))
import App.Server.Watch
import App.Submodels.Context exposing (Context)
import App.Submodels.LocalCotos exposing (LocalCotos)
import App.Types.Post exposing (Post)
import App.Types.Timeline
import App.Types.Watch exposing (Watch)
import Date
import List.Extra
import Time exposing (Time)
import Utils.UpdateUtil exposing (..)


clearUnread :
    Context context
    -> LocalCotos model
    -> ( LocalCotos model, Cmd Msg )
clearUnread context model =
    model.timeline
        |> App.Types.Timeline.latestPost
        |> Maybe.map (\latestPost -> updateByPost context latestPost model)
        |> Maybe.withDefault ( model, Cmd.none )


updateByPost : Context context -> Post -> LocalCotos model -> ( LocalCotos model, Cmd Msg )
updateByPost context post model =
    context
        |> App.Submodels.Context.findWatchForCurrentCotonoma
        |> Maybe.map
            (\watch ->
                post.postedAt
                    |> Maybe.map Date.toTime
                    |> Maybe.map (\timestamp -> updateTimestamp context timestamp watch model)
                    |> Maybe.withDefault ( model, Cmd.none )
            )
        |> Maybe.withDefault ( model, Cmd.none )


updateTimestamp :
    Context context
    -> Time
    -> Watch
    -> LocalCotos model
    -> ( LocalCotos model, Cmd Msg )
updateTimestamp context timestamp watch model =
    let
        isNewPost =
            watch.lastPostTimestamp
                |> Maybe.map (\watchTimestamp -> watchTimestamp < timestamp)
                |> Maybe.withDefault True
    in
    if not model.watchUpdating && isNewPost then
        let
            watchlist =
                model.watchlist
                    |> List.Extra.updateIf
                        (\w -> w.cotonoma.id == watch.cotonoma.id)
                        (\w -> { w | lastPostTimestamp = Just timestamp })
        in
        { model | watchlist = watchlist, watchUpdating = True }
            |> withCmd
                (\_ ->
                    App.Server.Watch.updateLastPostTimestamp
                        WatchTimestampUpdated
                        context.clientId
                        watch.cotonoma.key
                        timestamp
                )

    else
        ( model, Cmd.none )
