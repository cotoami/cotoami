module App.Types.Watch exposing (Watch, isWatched)

import App.Types.Coto exposing (Cotonoma)


type alias Watch =
    { id : String
    , cotonoma : Cotonoma
    , lastPostTimestamp : Maybe Int
    }


isWatched : List Watch -> Cotonoma -> Bool
isWatched watchlist cotonoma =
    List.any (\watch -> watch.cotonoma.id == cotonoma.id) watchlist
