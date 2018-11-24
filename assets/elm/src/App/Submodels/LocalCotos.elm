module App.Submodels.LocalCotos
    exposing
        ( LocalCotos
        , getCoto
        , getSelectedCotos
        , getCotoIdsToWatch
        , updateCoto
        , deleteCoto
        , cotonomatize
        , incorporateLocalCotoInGraph
        , updateRecentCotonomas
        , isStockEmpty
        , isNavigationEmpty
        , connect
        , areTimelineAndGraphLoaded
        , isTimelineReady
        , findWatchForCurrentCotonoma
        )

import Set exposing (Set)
import Dict
import Date
import List.Extra
import Exts.Maybe
import App.Types.Coto exposing (Coto, CotoId, Cotonoma)
import App.Types.Timeline exposing (Timeline)
import App.Types.SearchResults exposing (SearchResults)
import App.Types.Connection exposing (Direction)
import App.Types.Graph exposing (Graph)
import App.Types.Session exposing (Session)
import App.Types.Watch exposing (Watch)
import App.Submodels.Context exposing (Context)


type alias LocalCotos a =
    { a
        | cotonoma : Maybe Cotonoma
        , cotonomaLoading : Bool
        , timeline : Timeline
        , graph : Graph
        , loadingGraph : Bool
        , globalCotonomas : List Cotonoma
        , recentCotonomas : List Cotonoma
        , subCotonomas : List Cotonoma
        , cotonomasLoading : Bool
        , watchlist : List Watch
        , watchlistLoading : Bool
        , searchResults : SearchResults
    }


getCoto : CotoId -> LocalCotos a -> Maybe Coto
getCoto cotoId localCotos =
    Exts.Maybe.oneOf
        [ Dict.get cotoId localCotos.graph.cotos
        , App.Types.Timeline.getCoto cotoId localCotos.timeline
        , App.Types.SearchResults.getCoto cotoId localCotos.searchResults
        , getCotoFromCotonomaList cotoId localCotos.globalCotonomas
        , getCotoFromCotonomaList cotoId localCotos.recentCotonomas
        , getCotoFromCotonomaList cotoId localCotos.subCotonomas
        , getCotoFromCotonomaList cotoId (List.map (.cotonoma) localCotos.watchlist)
        , localCotos.cotonoma
            |> Maybe.map
                (\cotonoma ->
                    if cotonoma.cotoId == cotoId then
                        Just (App.Types.Coto.toCoto cotonoma)
                    else
                        Nothing
                )
            |> Maybe.withDefault Nothing
        ]


getSelectedCotos : Context a -> LocalCotos b -> List Coto
getSelectedCotos context localCotos =
    context.selection
        |> List.filterMap (\cotoId -> getCoto cotoId localCotos)
        |> List.reverse


getCotoFromCotonomaList : CotoId -> List Cotonoma -> Maybe Coto
getCotoFromCotonomaList cotoId cotonomas =
    cotonomas
        |> List.filter (\cotonoma -> cotonoma.cotoId == cotoId)
        |> List.head
        |> Maybe.map App.Types.Coto.toCoto


getCotoIdsToWatch : LocalCotos a -> Set CotoId
getCotoIdsToWatch localCotos =
    localCotos.timeline.posts
        |> List.filterMap (\post -> post.cotoId)
        |> List.append (Dict.keys localCotos.graph.cotos)
        |> List.append
            (localCotos.cotonoma
                |> Maybe.map (\cotonoma -> [ cotonoma.cotoId ])
                |> Maybe.withDefault []
            )
        |> Set.fromList


updateCoto : Coto -> LocalCotos a -> LocalCotos a
updateCoto coto localCotos =
    { localCotos
        | timeline = App.Types.Timeline.updatePost coto localCotos.timeline
        , graph = App.Types.Graph.updateCoto coto localCotos.graph
    }


deleteCoto : Coto -> LocalCotos a -> LocalCotos a
deleteCoto coto localCotos =
    { localCotos
        | timeline = App.Types.Timeline.deleteCoto coto localCotos.timeline
        , graph = App.Types.Graph.removeCoto coto.id localCotos.graph
    }


cotonomatize : Cotonoma -> CotoId -> LocalCotos a -> LocalCotos a
cotonomatize cotonoma cotoId localCotos =
    { localCotos
        | timeline = App.Types.Timeline.cotonomatize cotonoma cotoId localCotos.timeline
        , graph = App.Types.Graph.cotonomatize cotonoma cotoId localCotos.graph
    }


incorporateLocalCotoInGraph : CotoId -> LocalCotos a -> LocalCotos a
incorporateLocalCotoInGraph cotoId localCotos =
    { localCotos
        | graph =
            if App.Types.Graph.member cotoId localCotos.graph then
                localCotos.graph
            else
                case getCoto cotoId localCotos of
                    Nothing ->
                        localCotos.graph

                    Just coto ->
                        App.Types.Graph.addCoto coto localCotos.graph
    }


updateRecentCotonomas : Maybe Cotonoma -> LocalCotos a -> LocalCotos a
updateRecentCotonomas maybeCotonoma localCotos =
    maybeCotonoma
        |> Maybe.map
            (\cotonoma ->
                localCotos.recentCotonomas
                    |> (::) cotonoma
                    |> List.Extra.uniqueBy (\c -> c.id)
                    |> List.sortBy (\c -> Date.toTime c.updatedAt)
                    |> List.reverse
                    |> (\cotonomas -> { localCotos | recentCotonomas = cotonomas })
            )
        |> Maybe.withDefault localCotos


isStockEmpty : LocalCotos a -> Bool
isStockEmpty localCotos =
    List.isEmpty localCotos.graph.rootConnections


isNavigationEmpty : LocalCotos a -> Bool
isNavigationEmpty localCotos =
    (Exts.Maybe.isNothing localCotos.cotonoma)
        && (List.isEmpty localCotos.globalCotonomas)
        && (List.isEmpty localCotos.recentCotonomas)
        && (List.isEmpty localCotos.subCotonomas)


connect : Maybe Session -> Direction -> List Coto -> Coto -> LocalCotos a -> LocalCotos a
connect maybeSession direction cotos target localCotos =
    let
        graph =
            maybeSession
                |> Maybe.map
                    (\session ->
                        App.Types.Graph.batchConnect
                            session.amishi.id
                            direction
                            cotos
                            target
                            localCotos.graph
                    )
                |> Maybe.withDefault localCotos.graph
    in
        { localCotos | graph = graph }


areTimelineAndGraphLoaded : LocalCotos a -> Bool
areTimelineAndGraphLoaded localCotos =
    (not localCotos.timeline.loading) && (not localCotos.loadingGraph)


isTimelineReady : LocalCotos a -> Bool
isTimelineReady localCotos =
    (areTimelineAndGraphLoaded localCotos)
        && (not localCotos.timeline.initializingScrollPos)


findWatchForCurrentCotonoma : LocalCotos a -> Maybe Watch
findWatchForCurrentCotonoma localCotos =
    localCotos.cotonoma
        |> Maybe.andThen
            (\cotonoma ->
                App.Types.Watch.findWatchByCotonomaId
                    cotonoma.id
                    localCotos.watchlist
            )
