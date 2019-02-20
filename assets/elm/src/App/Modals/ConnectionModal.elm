module App.Modals.ConnectionModal exposing (Model, initModel)

import App.Types.Coto exposing (Coto)


type alias Model =
    { startCoto : Coto
    , endCoto : Coto
    , linkingPhrase : String
    }


initModel : Coto -> Coto -> Maybe String -> Model
initModel startCoto endCoto linkingPhrase =
    { startCoto = startCoto
    , endCoto = endCoto
    , linkingPhrase = linkingPhrase |> Maybe.withDefault ""
    }
