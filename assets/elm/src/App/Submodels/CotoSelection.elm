module App.Submodels.CotoSelection exposing
    ( CotoSelection
    , anySelection
    , clearSelection
    , deselect
    , finishBeingDeselected
    , isSelected
    , setBeingDeselected
    , toggleSelection
    , updateCoto
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
    { model | selection = List.filter (\coto -> coto.id /= cotoId) model.selection }


toggleSelection : Coto -> CotoSelection model -> CotoSelection model
toggleSelection coto model =
    if isSelected coto.id model then
        deselect coto.id model

    else
        { model | selection = coto :: model.selection }


clearSelection : CotoSelection model -> CotoSelection model
clearSelection model =
    { model | selection = [] }


updateCoto : Coto -> CotoSelection model -> CotoSelection model
updateCoto newCoto model =
    let
        selection =
            List.map
                (\coto ->
                    if coto.id == newCoto.id then
                        newCoto

                    else
                        coto
                )
                model.selection
    in
    { model | selection = selection }


setBeingDeselected : CotoId -> CotoSelection model -> CotoSelection model
setBeingDeselected cotoId model =
    { model | deselecting = Set.insert cotoId model.deselecting }


finishBeingDeselected : CotoSelection model -> CotoSelection model
finishBeingDeselected model =
    { model
        | selection =
            List.filter
                (\coto -> not (Set.member coto.id model.deselecting))
                model.selection
        , deselecting = Set.empty
    }
