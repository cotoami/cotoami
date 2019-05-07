module App.Submodels.CotoSelection exposing
    ( CotoSelection
    , anySelection
    , clear
    , cotosInSelectedOrder
    , deselect
    , finishBeingDeselected
    , isBeingDeselected
    , isSelected
    , setBeingDeselected
    , toggleSelection
    )

import App.Types.Coto exposing (Coto, CotoId)
import Set exposing (Set)


type alias CotoSelection a =
    { a
        | selection : List Coto
        , deselecting : Set CotoId
    }


anySelection : CotoSelection model -> Bool
anySelection model =
    not (List.isEmpty model.selection)


isSelected : CotoId -> CotoSelection model -> Bool
isSelected cotoId model =
    List.any (\coto -> coto.id == cotoId) model.selection


deselect : CotoId -> CotoSelection model -> CotoSelection model
deselect cotoId model =
    { model | selection = App.Types.Coto.removeFromList cotoId model.selection }


toggleSelection : Coto -> CotoSelection model -> CotoSelection model
toggleSelection coto model =
    if isSelected coto.id model then
        deselect coto.id model

    else
        { model | selection = coto :: model.selection }


clear : CotoSelection model -> CotoSelection model
clear model =
    { model | selection = [] }


cotosInSelectedOrder : CotoSelection model -> List Coto
cotosInSelectedOrder model =
    List.reverse model.selection


setBeingDeselected : CotoId -> CotoSelection model -> CotoSelection model
setBeingDeselected cotoId model =
    { model | deselecting = Set.insert cotoId model.deselecting }


isBeingDeselected : CotoId -> CotoSelection model -> Bool
isBeingDeselected cotoId model =
    Set.member cotoId model.deselecting


finishBeingDeselected : CotoSelection model -> CotoSelection model
finishBeingDeselected model =
    { model
        | selection =
            List.filter
                (\coto -> not (Set.member coto.id model.deselecting))
                model.selection
        , deselecting = Set.empty
    }
