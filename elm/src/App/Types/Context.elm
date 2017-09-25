module App.Types.Context exposing (..)

import Set exposing (Set)
import Uuid
import Random.Pcg exposing (initialSeed, step)
import Keyboard exposing (KeyCode)
import Util.Keys exposing (Modifier(..), isModifier, toModifier)
import App.Types.Session exposing (Session)
import App.Types.Coto exposing (ElementId, CotoId, Cotonoma)


type alias CotoSelection = List CotoId


type alias Context =
    { clientId : String
    , session : Maybe Session
    , cotonoma : Maybe Cotonoma
    , elementFocus : Maybe ElementId
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
            |> \( uuid, _ ) -> Uuid.toString uuid
    , session = Nothing
    , cotonoma = Nothing
    , elementFocus = Nothing
    , cotoFocus = Nothing
    , selection = []
    , deselecting = Set.empty
    , modifierKeys = Set.empty
    }


setSession : Session -> Context -> Context
setSession session context =
    { context | session = Just session }


setElementFocus : Maybe String -> Context -> Context
setElementFocus maybeElementId context =
    { context | elementFocus = maybeElementId }


setCotoFocus : Maybe CotoId -> Context -> Context
setCotoFocus maybeCotoId context =
    { context | cotoFocus = maybeCotoId }


isSelected : Maybe CotoId -> Context -> Bool
isSelected maybeCotoId context =
    case maybeCotoId of
        Nothing -> False
        Just cotoId -> List.member cotoId context.selection


updateSelection : CotoId -> Context -> Context
updateSelection cotoId context =
    { context
    | selection =
        if context.selection |> List.member cotoId  then
            List.filter (\id -> cotoId /= id) context.selection
        else
            cotoId :: context.selection
    }


clearCotonoma : Context -> Context
clearCotonoma context =
    { context | cotonoma = Nothing }


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
        |> List.any (\keyCode ->
            case toModifier keyCode of
                Nothing -> False
                Just modifier ->
                    case modifier of
                        Ctrl -> True
                        Meta -> True
                        _ -> False
        )


isAltDown : Context -> Bool
isAltDown context =
    context.modifierKeys
        |> Set.toList
        |> List.any (\keyCode ->
            case toModifier keyCode of
                Nothing -> False
                Just modifier ->
                    case modifier of
                        Alt -> True
                        _ -> False
        )
