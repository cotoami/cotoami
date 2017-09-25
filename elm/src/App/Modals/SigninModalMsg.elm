module App.Modals.SigninModalMsg exposing (Msg(..))

import Http


type Msg
    = EmailInput String
    | RequestClick
    | RequestDone (Result Http.Error String)
