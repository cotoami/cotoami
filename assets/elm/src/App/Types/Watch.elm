module App.Types.Watch exposing
    ( Watch
    , anyUnreadCotos
    , anyUnreadCotosInCotonoma
    , findWatchByCotonomaId
    )

import App.Types.Coto exposing (Cotonoma)
import Exts.Maybe exposing (isJust)
import List.Extra
import Time exposing (Time)


type alias Watch =
    { id : String
    , cotonoma : Cotonoma
    , lastPostTimestamp : Maybe Time
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


findWatchByCotonomaId : String -> List Watch -> Maybe Watch
findWatchByCotonomaId cotonomaId watchlist =
    List.Extra.find (\watch -> watch.cotonoma.id == cotonomaId) watchlist


anyUnreadCotosInCotonoma : List Watch -> Cotonoma -> Bool
anyUnreadCotosInCotonoma watchlist cotonoma =
    watchlist
        |> findWatchByCotonomaId cotonoma.id
        |> Maybe.map anyUnreadCotos
        |> Maybe.withDefault False
