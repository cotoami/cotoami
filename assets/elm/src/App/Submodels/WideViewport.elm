module App.Submodels.WideViewport exposing
    ( WideViewport
    , WideViewportState
    , closeSelection
    , closeSelectionIfEmpty
    , defaultWideViewportState
    , toggleFlow
    , toggleNav
    , toggleSelection
    )

import App.Submodels.Context exposing (Context)


type alias WideViewportState =
    { navHidden : Bool
    , flowHidden : Bool
    , selectionOpen : Bool
    }


defaultWideViewportState : WideViewportState
defaultWideViewportState =
    { navHidden = False
    , flowHidden = False
    , selectionOpen = False
    }


type alias WideViewport model =
    { model | wideViewport : WideViewportState }


toggleNav : WideViewport model -> WideViewport model
toggleNav ({ wideViewport } as model) =
    { model
        | wideViewport =
            { wideViewport | navHidden = not wideViewport.navHidden }
    }


toggleFlow : WideViewport model -> WideViewport model
toggleFlow ({ wideViewport } as model) =
    { model
        | wideViewport =
            { wideViewport | flowHidden = not wideViewport.flowHidden }
    }


toggleSelection : WideViewport model -> WideViewport model
toggleSelection ({ wideViewport } as model) =
    { model
        | wideViewport =
            { wideViewport | selectionOpen = not wideViewport.selectionOpen }
    }


closeSelection : WideViewport model -> WideViewport model
closeSelection ({ wideViewport } as model) =
    { model | wideViewport = { wideViewport | selectionOpen = False } }


closeSelectionIfEmpty : Context context -> WideViewport model -> WideViewport model
closeSelectionIfEmpty context model =
    if List.isEmpty context.selection then
        closeSelection model

    else
        model
