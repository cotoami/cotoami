module App.Commands.Cotonoma exposing (refreshCotonomaList)

import App.Submodels.Context exposing (Context)
import App.Messages exposing (Msg)
import App.Server.Cotonoma


refreshCotonomaList : Context a -> Cmd Msg
refreshCotonomaList context =
    Cmd.batch
        [ App.Server.Cotonoma.fetchCotonomas
        , App.Server.Cotonoma.fetchSubCotonomas context
        ]
