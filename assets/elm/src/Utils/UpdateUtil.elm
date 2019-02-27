module Utils.UpdateUtil exposing
    ( addCmd
    , addCmdIf
    , chain
    , withCmd
    , withCmdIf
    , withCmds
    , withoutCmd
    )


withCmd : (model -> Cmd msg) -> model -> ( model, Cmd msg )
withCmd createCmd model =
    ( model, createCmd model )


withCmds : (model -> List (Cmd msg)) -> model -> ( model, Cmd msg )
withCmds createCmds model =
    ( model, Cmd.batch (createCmds model) )


withCmdIf : (model -> Bool) -> (model -> Cmd msg) -> model -> ( model, Cmd msg )
withCmdIf condition createCmd model =
    if condition model then
        withCmd createCmd model

    else
        ( model, Cmd.none )


withoutCmd : model -> ( model, Cmd msg )
withoutCmd model =
    ( model, Cmd.none )


addCmd : (model -> Cmd msg) -> ( model, Cmd msg ) -> ( model, Cmd msg )
addCmd createCmd ( model, cmd ) =
    ( model, Cmd.batch [ cmd, createCmd model ] )


addCmdIf : (model -> Bool) -> (model -> Cmd msg) -> ( model, Cmd msg ) -> ( model, Cmd msg )
addCmdIf condition createCmd ( model, cmd ) =
    if condition model then
        addCmd createCmd ( model, cmd )

    else
        ( model, cmd )


chain : (model -> ( model, Cmd msg )) -> ( model, Cmd msg ) -> ( model, Cmd msg )
chain update ( model, cmd1 ) =
    update model |> (\( model, cmd2 ) -> ( model, Cmd.batch [ cmd1, cmd2 ] ))
