module App.Submodels.Context
    exposing
        ( Context
        , generateClientId
        , isServerOwner
        , atHome
        , focusCoto
        , clearCotoFocus
        , toggleContent
        , toggleReorderMode
        , inReorderMode
        , contentOpen
        , anySelection
        , isSelected
        , updateSelection
        , clearSelection
        , deleteSelection
        , setBeingDeselected
        , finishBeingDeselected
        , setCotonomaLoading
        , setCotonoma
        , orignatedHere
        )

import Set exposing (Set)
import Random.Pcg
import Uuid
import Exts.Maybe exposing (isNothing)
import Utils.HttpUtil exposing (ClientId(ClientId))
import App.Types.Session exposing (Session)
import App.Types.Coto exposing (ElementId, Coto, CotoId, Cotonoma, CotoSelection)


type alias Context a =
    { a
        | clientId : ClientId
        , session : Maybe Session
        , cotonoma : Maybe Cotonoma
        , cotonomaLoading : Bool
        , elementFocus : Maybe ElementId
        , contentOpenElements : Set ElementId
        , reorderModeElements : Set ElementId
        , cotoFocus : Maybe CotoId
        , selection : CotoSelection
        , deselecting : Set CotoId
    }


generateClientId : Int -> ClientId
generateClientId seed =
    Random.Pcg.initialSeed seed
        |> Random.Pcg.step Uuid.uuidGenerator
        |> \( uuid, _ ) -> ClientId (Uuid.toString uuid)


isServerOwner : Context a -> Bool
isServerOwner context =
    context.session
        |> Maybe.map (\session -> session.owner)
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


toggleReorderMode : ElementId -> Context a -> Context a
toggleReorderMode elementId context =
    { context
        | reorderModeElements =
            toggleSetMember elementId context.reorderModeElements
    }


toggleSetMember : comparable -> Set comparable -> Set comparable
toggleSetMember value set =
    if Set.member value set then
        Set.remove value set
    else
        Set.insert value set


inReorderMode : ElementId -> Context a -> Bool
inReorderMode elementId context =
    Set.member elementId context.reorderModeElements


contentOpen : ElementId -> Context a -> Bool
contentOpen elementId context =
    Set.member elementId context.contentOpenElements


anySelection : Context a -> Bool
anySelection context =
    not (List.isEmpty context.selection)


isSelected : Maybe CotoId -> Context a -> Bool
isSelected maybeCotoId context =
    maybeCotoId
        |> Maybe.map (\cotoId -> List.member cotoId context.selection)
        |> Maybe.withDefault False


updateSelection : CotoId -> Context a -> Context a
updateSelection cotoId context =
    { context
        | selection =
            if context.selection |> List.member cotoId then
                List.filter (\id -> cotoId /= id) context.selection
            else
                cotoId :: context.selection
    }


clearSelection : Context a -> Context a
clearSelection context =
    { context | selection = [] }


deleteSelection : CotoId -> Context a -> Context a
deleteSelection cotoId context =
    { context | selection = List.filter (\id -> cotoId /= id) context.selection }


setBeingDeselected : CotoId -> Context a -> Context a
setBeingDeselected cotoId context =
    { context
        | deselecting =
            context.deselecting |> Set.insert cotoId
    }


finishBeingDeselected : Context a -> Context a
finishBeingDeselected context =
    { context
        | selection =
            List.filter
                (\id -> not (Set.member id context.deselecting))
                context.selection
        , deselecting = Set.empty
    }


setCotonomaLoading : Context a -> Context a
setCotonomaLoading context =
    { context | cotonoma = Nothing, cotonomaLoading = True }


setCotonoma : Maybe Cotonoma -> Context a -> Context a
setCotonoma maybeCotonoma context =
    { context | cotonoma = maybeCotonoma, cotonomaLoading = False }


orignatedHere : Context a -> Coto -> Bool
orignatedHere context coto =
    (Maybe.map2
        (\here postedIn -> here.id == postedIn.id)
        context.cotonoma
        coto.postedIn
    )
        |> Maybe.withDefault
            ((isNothing coto.postedIn) && (atHome context))
