module Util.UpdateUtil
    exposing
        ( withCmd
        , withCmds
        , withCmdIf
        , withoutCmd
        , addCmd
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
