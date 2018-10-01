module App.Views.Reorder
    exposing
        ( Reordering(..)
        )

import App.Types.Coto exposing (ElementId)


type Reordering
    = PinnedCotos
    | SubCotos ElementId
