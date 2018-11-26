module App.Update.Watch
    exposing
        ( clearUnreadInCurrentCotonoma
        , updateWatchByPost
        )

import Date
import Time exposing (Time)
import List.Extra
import Utils.UpdateUtil exposing (..)
import App.Messages exposing (Msg(WatchTimestampUpdated))
import App.Types.Watch exposing (Watch)
import App.Types.Post exposing (Post)
import App.Types.Timeline
import App.Submodels.Context exposing (Context)
import App.Submodels.LocalCotos exposing (LocalCotos)
import App.Server.Watch


clearUnreadInCurrentCotonoma :
    Context context
    -> LocalCotos model
    -> ( LocalCotos model, Cmd Msg )
clearUnreadInCurrentCotonoma context model =
    (Maybe.map2
        (\cotonoma latestPost ->
            model.watchlist
                |> App.Types.Watch.findWatchByCotonomaId cotonoma.id
                |> Maybe.map (\watch -> updateWatchByPost context latestPost watch model)
                |> Maybe.withDefault ( model, Cmd.none )
        )
        model.cotonoma
        (App.Types.Timeline.latestPost model.timeline)
    )
        |> Maybe.withDefault ( model, Cmd.none )


updateWatchByPost :
    Context context
    -> Post
    -> Watch
    -> LocalCotos model
    -> ( LocalCotos model, Cmd Msg )
updateWatchByPost context post watch model =
    post.postedAt
        |> Maybe.map Date.toTime
        |> Maybe.map (\timestamp -> updateWatchTimestamp context timestamp watch model)
        |> Maybe.withDefault ( model, Cmd.none )


updateWatchTimestamp :
    Context context
    -> Time
    -> Watch
    -> LocalCotos model
    -> ( LocalCotos model, Cmd Msg )
updateWatchTimestamp context timestamp watch model =
    let
        isNewPost =
            watch.lastPostTimestamp
                |> Maybe.map (\watchTimestamp -> watchTimestamp < timestamp)
                |> Maybe.withDefault True
    in
        if (not model.watchUpdating) && isNewPost then
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
                                (WatchTimestampUpdated)
                                context.clientId
                                watch.cotonoma.key
                                timestamp
                        )
        else
            ( model, Cmd.none )
