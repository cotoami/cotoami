module App.Commands.Cotonoma exposing (refreshCotonomaList)

import App.Model exposing (Model)
import App.Messages exposing (Msg)
import App.Server.Cotonoma


refreshCotonomaList : Model -> Cmd Msg
refreshCotonomaList model =
    Cmd.batch
        [ App.Server.Cotonoma.fetchCotonomas
        , App.Server.Cotonoma.fetchSubCotonomas model
        ]
