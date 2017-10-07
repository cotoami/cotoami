module App.Modals.ImportModalMsg exposing (Msg(..))

import Http


type Msg
    = DataInput String
    | ImportClick
    | ImportDone (Result Http.Error ( Int, Int ))
