module App.Submodels.LocalCotos exposing
    ( LocalCotos
    , areTimelineAndGraphLoaded
    , connect
    , cotonomatize
    , deleteCoto
    , getCoto
    , getCotoIdsToWatch
    , getCotonomaKeysToWatch
    , getSelectedCotos
    , incorporateLocalCotoInGraph
    , isNavigationEmpty
    , isStockEmpty
    , isTimelineReady
    , onPosted
    , updateCoto
    , updateCotonoma
    , updateCotonomaMaybe
    )

import App.Submodels.Context exposing (Context)
import App.Types.Connection exposing (Direction)
import App.Types.Coto exposing (Coto, CotoId, Cotonoma, CotonomaKey)
import App.Types.Graph exposing (Graph)
import App.Types.Graph.Connect
import App.Types.Post exposing (Post)
import App.Types.SearchResults exposing (SearchResults)
import App.Types.Session exposing (Session)
import App.Types.Timeline exposing (Timeline)
import App.Types.Watch exposing (Watch)
import Dict
import Exts.Maybe
import List.Extra
import Set exposing (Set)


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
        , watchUpdating : Bool
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
        , getCotoFromCotonomaList cotoId (List.map .cotonoma localCotos.watchlist)
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


getCotonomaKeysToWatch : LocalCotos a -> Set CotonomaKey
getCotonomaKeysToWatch localCotos =
    (localCotos.cotonoma
        |> Maybe.map List.singleton
        |> Maybe.withDefault []
    )
        |> List.append localCotos.globalCotonomas
        |> List.append localCotos.recentCotonomas
        |> List.append localCotos.subCotonomas
        |> List.append (List.map .cotonoma localCotos.watchlist)
        |> List.map .key
        |> Set.fromList


updateCoto : Coto -> LocalCotos a -> LocalCotos a
updateCoto coto localCotos =
    { localCotos
        | timeline = App.Types.Timeline.updatePost coto localCotos.timeline
        , graph = App.Types.Graph.updateCotoContent coto localCotos.graph
    }


updateCotonoma : Cotonoma -> LocalCotos a -> LocalCotos a
updateCotonoma cotonoma localCotos =
    { localCotos
        | cotonoma =
            if Maybe.map .id localCotos.cotonoma == Just cotonoma.id then
                Just cotonoma

            else
                localCotos.cotonoma
        , globalCotonomas = updateCotonomaInList cotonoma localCotos.globalCotonomas
        , recentCotonomas = updateCotonomaInList cotonoma localCotos.recentCotonomas
        , subCotonomas = updateCotonomaInList cotonoma localCotos.subCotonomas
        , watchlist =
            localCotos.watchlist
                |> List.Extra.updateIf
                    (\watch -> watch.cotonoma.id == cotonoma.id)
                    (\watch -> { watch | cotonoma = cotonoma })
    }


updateCotonomaMaybe : Maybe Cotonoma -> LocalCotos a -> LocalCotos a
updateCotonomaMaybe maybeCotonoma localCotos =
    maybeCotonoma
        |> Maybe.map (\cotonoma -> updateCotonoma cotonoma localCotos)
        |> Maybe.withDefault localCotos


updateCotonomaInList : Cotonoma -> List Cotonoma -> List Cotonoma
updateCotonomaInList cotonoma cotonomas =
    if List.any (\c -> c.id == cotonoma.id) cotonomas then
        cotonomas
            |> List.filter (\c -> c.id /= cotonoma.id)
            |> (::) cotonoma

    else
        cotonomas


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
                getCoto cotoId localCotos
                    |> Maybe.map (\coto -> App.Types.Graph.addCoto coto localCotos.graph)
                    |> Maybe.withDefault localCotos.graph
    }


isStockEmpty : LocalCotos a -> Bool
isStockEmpty localCotos =
    List.isEmpty localCotos.graph.rootConnections


isNavigationEmpty : LocalCotos a -> Bool
isNavigationEmpty localCotos =
    Exts.Maybe.isNothing localCotos.cotonoma
        && List.isEmpty localCotos.globalCotonomas
        && List.isEmpty localCotos.recentCotonomas
        && List.isEmpty localCotos.subCotonomas


connect :
    Maybe Session
    -> Coto
    -> List Coto
    -> Direction
    -> Maybe String
    -> LocalCotos a
    -> LocalCotos a
connect maybeSession target cotos direction linkingPhrase localCotos =
    let
        graph =
            maybeSession
                |> Maybe.map
                    (\session ->
                        App.Types.Graph.Connect.batch
                            session.amishi.id
                            target
                            cotos
                            direction
                            linkingPhrase
                            localCotos.graph
                    )
                |> Maybe.withDefault localCotos.graph
    in
    { localCotos | graph = graph }


areTimelineAndGraphLoaded : LocalCotos a -> Bool
areTimelineAndGraphLoaded localCotos =
    not localCotos.timeline.loading && not localCotos.loadingGraph


isTimelineReady : LocalCotos a -> Bool
isTimelineReady localCotos =
    areTimelineAndGraphLoaded localCotos
        && not localCotos.timeline.initializingScrollPos


onPosted : Int -> Post -> LocalCotos a -> LocalCotos a
onPosted postId post localCotos =
    { localCotos
        | timeline =
            App.Types.Timeline.setCotoSaved
                postId
                post
                localCotos.timeline
    }
        |> updateCotonomaMaybe post.postedIn
