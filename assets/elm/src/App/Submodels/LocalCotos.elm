module App.Submodels.LocalCotos exposing
    ( LocalCotos
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
        , selection : List Coto
    }


getCoto : CotoId -> LocalCotos model -> Maybe Coto
getCoto cotoId model =
    Exts.Maybe.oneOf
        [ Dict.get cotoId model.graph.cotos
        , App.Types.Timeline.getCoto cotoId model.timeline
        , App.Types.SearchResults.getCoto cotoId model.searchResults
        , App.Types.Coto.getCotoFromCotonomaList cotoId model.globalCotonomas
        , App.Types.Coto.getCotoFromCotonomaList cotoId model.recentCotonomas
        , App.Types.Coto.getCotoFromCotonomaList cotoId model.subCotonomas
        , App.Types.Coto.getCotoFromCotonomaList cotoId (List.map .cotonoma model.watchlist)
        , model.cotonoma
            |> Maybe.map
                (\cotonoma ->
                    if cotonoma.cotoId == cotoId then
                        Just (App.Types.Coto.toCoto cotonoma)

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
        |> List.append (List.filterMap .cotoId model.timeline.posts)
        |> List.append (Dict.keys model.graph.cotos)
        |> List.append (List.map .id model.selection)
        |> Set.fromList


cotonomaKeys : LocalCotos model -> Set CotonomaKey
cotonomaKeys model =
    model.cotonoma
        |> Maybe.map List.singleton
        |> Maybe.withDefault []
        |> List.append model.globalCotonomas
        |> List.append model.recentCotonomas
        |> List.append model.subCotonomas
        |> List.append (List.map .cotonoma model.watchlist)
        |> List.map .key
        |> Set.fromList


updateCoto : Coto -> LocalCotos model -> LocalCotos model
updateCoto coto model =
    { model
        | timeline = App.Types.Timeline.updatePost coto model.timeline
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
        , subCotonomas = updateCotonomaInList cotonoma model.subCotonomas
        , watchlist =
            model.watchlist
                |> List.Extra.updateIf
                    (\watch -> watch.cotonoma.id == cotonoma.id)
                    (\watch -> { watch | cotonoma = cotonoma })
    }


updateCotonomaMaybe : Maybe Cotonoma -> LocalCotos model -> LocalCotos model
updateCotonomaMaybe maybeCotonoma model =
    maybeCotonoma
        |> Maybe.map (\cotonoma -> updateCotonoma cotonoma model)
        |> Maybe.withDefault model


updateCotonomaInList : Cotonoma -> List Cotonoma -> List Cotonoma
updateCotonomaInList cotonoma cotonomas =
    if List.any (\c -> c.id == cotonoma.id) cotonomas then
        cotonomas
            |> List.filter (\c -> c.id /= cotonoma.id)
            |> (::) cotonoma

    else
        cotonomas


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
        , selection = App.Types.Coto.replaceInList (App.Types.Coto.toCoto cotonoma) model.selection
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
            App.Types.Timeline.setCotoSaved
                postId
                post
                model.timeline
    }
        |> updateCotonomaMaybe post.postedIn
