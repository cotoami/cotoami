module App.Types.Context exposing (..)

import Set exposing (Set)
import Uuid
import Random.Pcg exposing (initialSeed, step)
import Keyboard exposing (KeyCode)
import Exts.Maybe exposing (isNothing)
import Util.HttpUtil exposing (ClientId(ClientId))
import Util.Keys exposing (Modifier(..), isModifier, toModifier)
import App.Types.Session exposing (Session)
import App.Types.Coto exposing (ElementId, Coto, CotoId, Cotonoma)


type alias CotoSelection =
    List CotoId


type alias Context =
    { clientId : ClientId
    , session : Maybe Session
    , cotonoma : Maybe Cotonoma
    , cotonomaLoading : Bool
    , elementFocus : Maybe ElementId
    , contentOpenElements : Set ElementId
    , reorderModeElements : Set ElementId
    , cotoFocus : Maybe CotoId
    , selection : CotoSelection
    , deselecting : Set CotoId
    , modifierKeys : Set KeyCode
    }


initContext : Int -> Context
initContext seed =
    { clientId =
        initialSeed seed
            |> step Uuid.uuidGenerator
            |> \( uuid, _ ) -> ClientId (Uuid.toString uuid)
    , session = Nothing
    , cotonoma = Nothing
    , cotonomaLoading = False
    , elementFocus = Nothing
    , contentOpenElements = Set.empty
    , reorderModeElements = Set.empty
    , cotoFocus = Nothing
    , selection = []
    , deselecting = Set.empty
    , modifierKeys = Set.empty
    }


setSession : Session -> Context -> Context
setSession session context =
    { context | session = Just session }


isServerOwner : Context -> Bool
isServerOwner context =
    context.session
        |> Maybe.map (\session -> session.owner)
        |> Maybe.withDefault False


setElementFocus : Maybe String -> Context -> Context
setElementFocus maybeElementId context =
    { context | elementFocus = maybeElementId }


setCotoFocus : Maybe CotoId -> Context -> Context
setCotoFocus maybeCotoId context =
    { context | cotoFocus = maybeCotoId }


toggleContent : ElementId -> Context -> Context
toggleContent elementId context =
    { context
        | contentOpenElements =
            toggleSetMember elementId context.contentOpenElements
    }


toggleReorderMode : ElementId -> Context -> Context
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


contentOpen : ElementId -> Context -> Bool
contentOpen elementId context =
    Set.member elementId context.contentOpenElements


anySelection : Context -> Bool
anySelection context =
    not (List.isEmpty context.selection)


isSelected : Maybe CotoId -> Context -> Bool
isSelected maybeCotoId context =
    maybeCotoId
        |> Maybe.map (\cotoId -> List.member cotoId context.selection)
        |> Maybe.withDefault False


updateSelection : CotoId -> Context -> Context
updateSelection cotoId context =
    { context
        | selection =
            if context.selection |> List.member cotoId then
                List.filter (\id -> cotoId /= id) context.selection
            else
                cotoId :: context.selection
    }


setCotonomaLoading : Context -> Context
setCotonomaLoading context =
    { context | cotonoma = Nothing, cotonomaLoading = True }


setCotonoma : Maybe Cotonoma -> Context -> Context
setCotonoma maybeCotonoma context =
    { context | cotonoma = maybeCotonoma, cotonomaLoading = False }


clearSelection : Context -> Context
clearSelection context =
    { context | selection = [] }


deleteSelection : CotoId -> Context -> Context
deleteSelection cotoId context =
    { context | selection = List.filter (\id -> cotoId /= id) context.selection }


setBeingDeselected : CotoId -> Context -> Context
setBeingDeselected cotoId context =
    { context
        | deselecting =
            context.deselecting |> Set.insert cotoId
    }


finishBeingDeselected : Context -> Context
finishBeingDeselected context =
    { context
        | selection =
            List.filter
                (\id -> not (Set.member id context.deselecting))
                context.selection
        , deselecting = Set.empty
    }


keyDown : KeyCode -> Context -> Context
keyDown keyCode context =
    if isModifier keyCode then
        { context
            | modifierKeys = Set.insert keyCode context.modifierKeys
        }
    else
        context


keyUp : KeyCode -> Context -> Context
keyUp keyCode context =
    if isModifier keyCode then
        { context
            | modifierKeys = Set.remove keyCode context.modifierKeys
        }
    else
        context


isCtrlDown : Context -> Bool
isCtrlDown context =
    context.modifierKeys
        |> Set.toList
        |> List.any
            (\keyCode ->
                toModifier keyCode
                    |> Maybe.map
                        (\modifier ->
                            case modifier of
                                Ctrl ->
                                    True

                                Meta ->
                                    True

                                _ ->
                                    False
                        )
                    |> Maybe.withDefault False
            )


isAltDown : Context -> Bool
isAltDown context =
    context.modifierKeys
        |> Set.toList
        |> List.any
            (\keyCode ->
                toModifier keyCode
                    |> Maybe.map
                        (\modifier ->
                            case modifier of
                                Alt ->
                                    True

                                _ ->
                                    False
                        )
                    |> Maybe.withDefault False
            )


orignatedHere : Context -> Coto -> Bool
orignatedHere context coto =
    (Maybe.map2
        (\here postedIn -> here.id == postedIn.id)
        context.cotonoma
        coto.postedIn
    )
        |> Maybe.withDefault
            ((isNothing context.cotonoma)
                && (isNothing coto.postedIn)
            )
