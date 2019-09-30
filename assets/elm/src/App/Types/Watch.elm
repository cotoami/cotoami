module App.Types.Watch exposing
    ( Watch
    , anyUnreadCotos
    , anyUnreadCotosInCotonoma
    , findWatchByCotonomaId
    , sameCotonoma
    , updateCotonomaInWatchlist
    )

import App.Types.Coto exposing (Cotonoma, CotonomaHolder)
import Exts.Maybe exposing (isJust)
import List.Extra
import Time exposing (Time)


type alias Watch =
    { id : String
    , cotonomaHolder : CotonomaHolder
    , lastPostTimestamp : Maybe Time
    }


sameCotonoma : Watch -> Watch -> Bool
sameCotonoma watch1 watch2 =
    watch1.cotonomaHolder.cotonoma.id == watch2.cotonomaHolder.cotonoma.id


updateCotonomaInWatchlist : Cotonoma -> List Watch -> List Watch
updateCotonomaInWatchlist cotonoma watchlist =
    watchlist
        |> List.Extra.updateIf
            (\watch -> watch.cotonomaHolder.cotonoma.id == cotonoma.id)
            (\({ cotonomaHolder } as watch) ->
                { watch
                    | cotonomaHolder =
                        { cotonomaHolder | cotonoma = cotonoma }
                }
            )


anyUnreadCotos : Watch -> Bool
anyUnreadCotos watch =
    watch.lastPostTimestamp
        |> Maybe.map
            (\lastCheck ->
                watch.cotonomaHolder.cotonoma.lastPostTimestamp
                    |> Maybe.map (\lastPost -> lastPost > lastCheck)
                    |> Maybe.withDefault True
            )
        |> Maybe.withDefault
            (isJust watch.cotonomaHolder.cotonoma.lastPostTimestamp)


findWatchByCotonomaId : String -> List Watch -> Maybe Watch
findWatchByCotonomaId cotonomaId watchlist =
    List.Extra.find
        (\watch -> watch.cotonomaHolder.cotonoma.id == cotonomaId)
        watchlist


anyUnreadCotosInCotonoma : List Watch -> Cotonoma -> Bool
anyUnreadCotosInCotonoma watchlist cotonoma =
    watchlist
        |> findWatchByCotonomaId cotonoma.id
        |> Maybe.map anyUnreadCotos
        |> Maybe.withDefault False
