module App.Submodels.Context exposing
    ( Context
    , anyUnreadCotos
    , atHome
    , clearCotoFocus
    , contentOpen
    , findWatchForCurrentCotonoma
    , focusCoto
    , generateClientId
    , hasPinnedCotosInReordering
    , hasSubCotosInReordering
    , isServerOwner
    , isTriggerElementInReordering
    , isWatched
    , orignatedHere
    , setCotonoma
    , setCotonomaLoading
    , toggleContent
    )

import App.I18n.Keys exposing (TextKey)
import App.Types.Connection exposing (Reordering(..))
import App.Types.Coto exposing (Coto, CotoId, Cotonoma, ElementId)
import App.Types.Graph exposing (Graph)
import App.Types.Session exposing (Session)
import App.Types.Watch exposing (Watch)
import Exts.Maybe exposing (isNothing)
import Random.Pcg
import Set exposing (Set)
import Utils.HttpUtil exposing (ClientId(ClientId))
import Uuid


type alias Context a =
    { a
        | clientVersion : String
        , clientId : ClientId
        , i18nText : TextKey -> String
        , session : Maybe Session
        , cotonoma : Maybe Cotonoma
        , cotonomaLoading : Bool
        , watchStateOnCotonomaLoad : Maybe Watch
        , elementFocus : Maybe ElementId
        , contentOpenElements : Set ElementId
        , reordering : Maybe Reordering
        , cotoFocus : Maybe CotoId
        , selection : List Coto
        , deselecting : Set CotoId
        , graph : Graph
        , loadingGraph : Bool
        , watchlist : List Watch
        , watchlistLoading : Bool
    }


generateClientId : Int -> ClientId
generateClientId seed =
    Random.Pcg.initialSeed seed
        |> Random.Pcg.step Uuid.uuidGenerator
        |> (\( uuid, _ ) -> ClientId (Uuid.toString uuid))


isServerOwner : Context a -> Bool
isServerOwner context =
    context.session
        |> Maybe.map (\session -> session.amishi.owner)
        |> Maybe.withDefault False


atHome : Context a -> Bool
atHome context =
    isNothing context.cotonoma


focusCoto : ElementId -> CotoId -> Context a -> Context a
focusCoto elementId cotoId context =
    { context
        | elementFocus = Just elementId
        , cotoFocus = Just cotoId
    }


clearCotoFocus : Context a -> Context a
clearCotoFocus context =
    { context
        | elementFocus = Nothing
        , cotoFocus = Nothing
    }


toggleContent : ElementId -> Context a -> Context a
toggleContent elementId context =
    { context
        | contentOpenElements =
            toggleSetMember elementId context.contentOpenElements
    }


toggleSetMember : comparable -> Set comparable -> Set comparable
toggleSetMember value set =
    if Set.member value set then
        Set.remove value set

    else
        Set.insert value set


contentOpen : ElementId -> Context a -> Bool
contentOpen elementId context =
    Set.member elementId context.contentOpenElements


setCotonomaLoading : Context a -> Context a
setCotonomaLoading context =
    { context
        | cotonoma = Nothing
        , cotonomaLoading = True
        , watchStateOnCotonomaLoad = Nothing
    }


setCotonoma : Maybe Cotonoma -> Context a -> Context a
setCotonoma maybeCotonoma context =
    { context | cotonoma = maybeCotonoma, cotonomaLoading = False }


orignatedHere : Coto -> Context a -> Bool
orignatedHere coto context =
    Maybe.map2
        (\here postedIn -> here.id == postedIn.id)
        context.cotonoma
        coto.postedIn
        |> Maybe.withDefault
            (isNothing coto.postedIn && atHome context)


hasPinnedCotosInReordering : Context a -> Bool
hasPinnedCotosInReordering context =
    context.reordering
        |> Maybe.map
            (\reordering ->
                case reordering of
                    PinnedCoto _ ->
                        True

                    _ ->
                        False
            )
        |> Maybe.withDefault False


hasSubCotosInReordering : ElementId -> Context a -> Bool
hasSubCotosInReordering elementId context =
    context.reordering
        |> Maybe.map
            (\reordering ->
                case reordering of
                    SubCoto parentElementId _ ->
                        elementId == parentElementId

                    _ ->
                        False
            )
        |> Maybe.withDefault False


isTriggerElementInReordering : ElementId -> Context a -> Bool
isTriggerElementInReordering elementId context =
    context.reordering
        |> Maybe.map
            (\reordering ->
                case reordering of
                    PinnedCoto triggerElement ->
                        elementId == triggerElement

                    SubCoto _ triggerElement ->
                        elementId == triggerElement
            )
        |> Maybe.withDefault False


isWatched : Cotonoma -> Context a -> Bool
isWatched cotonoma context =
    List.any (\watch -> watch.cotonoma.id == cotonoma.id) context.watchlist


findWatchForCurrentCotonoma : Context a -> Maybe Watch
findWatchForCurrentCotonoma context =
    context.cotonoma
        |> Maybe.andThen
            (\cotonoma ->
                App.Types.Watch.findWatchByCotonomaId
                    cotonoma.id
                    context.watchlist
            )


anyUnreadCotos : Context a -> Bool
anyUnreadCotos context =
    List.any App.Types.Watch.anyUnreadCotos context.watchlist
