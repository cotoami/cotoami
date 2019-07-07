module App.Submodels.LocalCotos exposing
    ( LocalCotos
    , addPostIfPostedHere
    , areTimelineAndGraphLoaded
    , connect
    , cotoIds
    , cotonomaKeys
    , cotonomatize
    , deleteCoto
    , ensureCotoIsInGraph
    , getCoto
    , isNavigationEmpty
    , isStockEmpty
    , isTimelineReady
    , onPosted
    , updateCoto
    , updateCotonoma
    , updateCotonomaMaybe
    )

import App.Types.Connection exposing (Direction)
import App.Types.Coto exposing (Coto, CotoId, Cotonoma, CotonomaHolder, CotonomaKey)
import App.Types.Graph exposing (Graph)
import App.Types.Graph.Connect
import App.Types.Post exposing (Post)
import App.Types.SearchResults exposing (SearchResults)
import App.Types.Session exposing (Session)
import App.Types.Timeline exposing (Timeline)
import App.Types.Watch exposing (Watch)
import Date
import Dict
import Exts.Maybe
import Set exposing (Set)


type alias LocalCotos a =
    { a
        | cotonoma : Maybe Cotonoma
        , cotonomaHolder : Maybe CotonomaHolder
        , cotonomaLoading : Bool
        , timeline : Timeline
        , graph : Graph
        , loadingGraph : Bool
        , globalCotonomas : List CotonomaHolder
        , recentCotonomas : List CotonomaHolder
        , superCotonomas : List CotonomaHolder
        , subCotonomas : List CotonomaHolder
        , cotonomasLoading : Bool
        , watchlist : List Watch
        , watchlistLoading : Bool
        , watchUpdating : Bool
        , searchResults : SearchResults
        , selection : List Coto
    }


getCoto : CotoId -> LocalCotos model -> Maybe Coto
getCoto cotoId model =
    Exts.Maybe.oneOf
        [ Dict.get cotoId model.graph.cotos
        , App.Types.Timeline.getCoto cotoId model.timeline
        , App.Types.SearchResults.getCoto cotoId model.searchResults
        , App.Types.Coto.getCotoFromCotonomaHolders cotoId model.globalCotonomas
        , App.Types.Coto.getCotoFromCotonomaHolders cotoId model.recentCotonomas
        , App.Types.Coto.getCotoFromCotonomaHolders cotoId model.superCotonomas
        , App.Types.Coto.getCotoFromCotonomaHolders cotoId model.subCotonomas
        , model.watchlist
            |> List.map .cotonomaHolder
            |> App.Types.Coto.getCotoFromCotonomaHolders cotoId
        , model.cotonomaHolder
            |> Maybe.map
                (\holder ->
                    if holder.cotonoma.cotoId == cotoId then
                        Just (App.Types.Coto.toCoto holder)

                    else
                        Nothing
                )
            |> Maybe.withDefault Nothing
        ]


cotoIds : LocalCotos model -> Set CotoId
cotoIds model =
    model.cotonoma
        |> Maybe.map (\cotonoma -> [ cotonoma.cotoId ])
        |> Maybe.withDefault []
        |> List.append (App.Types.Timeline.cotoIds model.timeline)
        |> List.append (Dict.keys model.graph.cotos)
        |> List.append (List.map .id model.selection)
        |> Set.fromList


cotonomaKeys : LocalCotos model -> Set CotonomaKey
cotonomaKeys model =
    model.cotonomaHolder
        |> Maybe.map List.singleton
        |> Maybe.withDefault []
        |> List.append model.globalCotonomas
        |> List.append model.recentCotonomas
        |> List.append model.subCotonomas
        |> List.append (List.map .cotonomaHolder model.watchlist)
        |> List.map (\holder -> holder.cotonoma.key)
        |> Set.fromList


addPostIfPostedHere : Post -> LocalCotos model -> LocalCotos model
addPostIfPostedHere post model =
    if Maybe.map .id model.cotonoma == Maybe.map .id post.postedIn then
        { model | timeline = App.Types.Timeline.addPost post model.timeline }

    else
        model


updateCoto : Coto -> LocalCotos model -> LocalCotos model
updateCoto coto model =
    { model
        | timeline = App.Types.Timeline.updateCoto coto model.timeline
        , graph = App.Types.Graph.updateCotoContent coto model.graph
        , selection = App.Types.Coto.replaceInList coto model.selection
    }


updateCotonoma : Cotonoma -> LocalCotos model -> LocalCotos model
updateCotonoma cotonoma model =
    { model
        | cotonoma =
            if Maybe.map .id model.cotonoma == Just cotonoma.id then
                Just cotonoma

            else
                model.cotonoma
        , globalCotonomas = updateCotonomaInList cotonoma model.globalCotonomas
        , recentCotonomas = updateCotonomaInList cotonoma model.recentCotonomas
        , superCotonomas = updateCotonomaInList cotonoma model.superCotonomas
        , subCotonomas = updateCotonomaInList cotonoma model.subCotonomas
        , watchlist = App.Types.Watch.updateCotonomaInWatchlist cotonoma model.watchlist
    }


updateCotonomaMaybe : Maybe Cotonoma -> LocalCotos model -> LocalCotos model
updateCotonomaMaybe maybeCotonoma model =
    maybeCotonoma
        |> Maybe.map (\cotonoma -> updateCotonoma cotonoma model)
        |> Maybe.withDefault model


updateCotonomaInList : Cotonoma -> List CotonomaHolder -> List CotonomaHolder
updateCotonomaInList cotonoma holders =
    holders
        |> App.Types.Coto.updateCotonomaInHolders cotonoma
        |> List.sortBy (\holder -> Date.toTime holder.cotonoma.updatedAt)
        |> List.reverse


deleteCoto : CotoId -> LocalCotos model -> LocalCotos model
deleteCoto cotoId model =
    { model
        | timeline = App.Types.Timeline.deleteCoto cotoId model.timeline
        , graph = App.Types.Graph.removeCoto cotoId model.graph
        , selection = App.Types.Coto.removeFromList cotoId model.selection
    }


cotonomatize : Cotonoma -> CotoId -> LocalCotos model -> LocalCotos model
cotonomatize cotonoma cotoId model =
    { model
        | timeline = App.Types.Timeline.cotonomatize cotonoma cotoId model.timeline
        , graph = App.Types.Graph.cotonomatize cotonoma cotoId model.graph
        , selection =
            App.Types.Coto.updateInList
                cotoId
                (\coto -> { coto | asCotonoma = Just cotonoma })
                model.selection
    }


ensureCotoIsInGraph : CotoId -> LocalCotos model -> LocalCotos model
ensureCotoIsInGraph cotoId model =
    { model
        | graph =
            if App.Types.Graph.member cotoId model.graph then
                model.graph

            else
                getCoto cotoId model
                    |> Maybe.map (\coto -> App.Types.Graph.addCoto coto model.graph)
                    |> Maybe.withDefault model.graph
    }


isStockEmpty : LocalCotos model -> Bool
isStockEmpty model =
    List.isEmpty model.graph.rootConnections


isNavigationEmpty : LocalCotos model -> Bool
isNavigationEmpty model =
    Exts.Maybe.isNothing model.cotonoma
        && List.isEmpty model.globalCotonomas
        && List.isEmpty model.recentCotonomas
        && List.isEmpty model.subCotonomas


connect :
    Maybe Session
    -> Coto
    -> List Coto
    -> Direction
    -> Maybe String
    -> LocalCotos model
    -> LocalCotos model
connect maybeSession target cotos direction linkingPhrase model =
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
                            model.graph
                    )
                |> Maybe.withDefault model.graph
    in
    { model | graph = graph }


areTimelineAndGraphLoaded : LocalCotos model -> Bool
areTimelineAndGraphLoaded model =
    not model.timeline.loading && not model.loadingGraph


isTimelineReady : LocalCotos model -> Bool
isTimelineReady model =
    areTimelineAndGraphLoaded model
        && not model.timeline.initializingScrollPos


onPosted : Int -> Post -> LocalCotos model -> LocalCotos model
onPosted postId post model =
    { model
        | timeline =
            App.Types.Timeline.setPostSaved
                postId
                post
                model.timeline
    }
        |> updateCotonomaMaybe post.postedIn
