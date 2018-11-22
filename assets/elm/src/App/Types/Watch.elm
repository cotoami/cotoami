module App.Types.Watch
    exposing
        ( Watch
        , anyUnreadCotos
        , isWatched
        , anyUnreadCotosInCotonoma
        )

import List.Extra
import Exts.Maybe exposing (isJust)
import App.Types.Coto exposing (Cotonoma)


type alias Watch =
    { id : String
    , cotonoma : Cotonoma
    , lastPostTimestamp : Maybe Int
    }


anyUnreadCotos : Watch -> Bool
anyUnreadCotos watch =
    watch.lastPostTimestamp
        |> Maybe.map
            (\lastCheck ->
                watch.cotonoma.lastPostTimestamp
                    |> Maybe.map (\lastPost -> lastPost > lastCheck)
                    |> Maybe.withDefault True
            )
        |> Maybe.withDefault (isJust watch.cotonoma.lastPostTimestamp)


isWatched : List Watch -> Cotonoma -> Bool
isWatched watchlist cotonoma =
    List.any (\watch -> watch.cotonoma.id == cotonoma.id) watchlist


anyUnreadCotosInCotonoma : List Watch -> Cotonoma -> Bool
anyUnreadCotosInCotonoma watchlist cotonoma =
    watchlist
        |> List.Extra.find (\watch -> watch.cotonoma.id == cotonoma.id)
        |> Maybe.map anyUnreadCotos
        |> Maybe.withDefault False
