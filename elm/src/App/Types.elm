module App.Types exposing (..)

import Set
import Dict
import App.Types.Amishi exposing (..)
import App.Types.Session exposing (Session)
import App.Types.Coto exposing (CotoId, Cotonoma, CotonomaKey)


type Route
    = HomeRoute
    | CotonomaRoute CotonomaKey
    | NotFoundRoute


type ViewInMobile
    = TimelineView
    | PinnedView
    | TraversalsView
    | SelectionView


type alias CotoSelection = List CotoId


type alias Context =
    { clientId : String
    , session : Maybe Session
    , cotonoma : Maybe Cotonoma
    , focus : Maybe CotoId
    , selection : CotoSelection
    , deselecting : Set.Set CotoId
    , ctrlDown : Bool
    }


setFocus : Maybe CotoId -> Context -> Context
setFocus maybeCotoId context =
    { context | focus = maybeCotoId }


updateFocus : CotoId -> Context -> Context
updateFocus cotoId context =
    { context
    | focus =
        case context.focus of
            Nothing -> Just cotoId
            Just focus ->
                if focus == cotoId then
                    Nothing
                else
                    Just cotoId
    }


isSelected : CotoId -> Context -> Bool
isSelected cotoId context =
    List.member cotoId context.selection


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


type alias MemberConnCounts = Dict.Dict AmishiId Int
