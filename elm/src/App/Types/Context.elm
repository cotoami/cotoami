module App.Types.Context exposing (..)

import Set
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
    , deselecting : Set.Set CotoId
    , ctrlDown : Bool
    }


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


ctrlDown : Bool -> Context -> Context
ctrlDown down context =
    { context | ctrlDown = down }
