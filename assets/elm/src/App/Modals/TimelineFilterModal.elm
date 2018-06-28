module App.Modals.TimelineFilterModal exposing (view)

import Html exposing (..)
import Util.Modal as Modal
import App.Messages exposing (Msg(CloseModal))
import App.Types.Context exposing (Context)
import App.Types.Timeline exposing (Filter)


view : Context -> Filter -> Html Msg
view context filter =
    Modal.view
        "timeline-filter-modal"
        (Just (modalConfig context filter))


modalConfig : Context -> Filter -> Modal.Config Msg
modalConfig context filter =
    { closeMessage = CloseModal
    , title = text ""
    , content =
        div [] [ text "Hello" ]
    , buttons = []
    }
