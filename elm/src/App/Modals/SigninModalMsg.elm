module App.Modals.SigninModalMsg exposing (Msg(..))

import Http


type Msg
    = EmailInput String
    | SaveAnonymousCotosCheck Bool
    | RequestClick
    | RequestDone (Result Http.Error String)
