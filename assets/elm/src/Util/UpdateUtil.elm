module Util.UpdateUtil exposing (withCmd, withCmdIf, withoutCmd, addCmd)


withCmd : (model -> Cmd msg) -> model -> ( model, Cmd msg )
withCmd createCmd model =
    ( model, createCmd model )


withCmdIf : Bool -> (model -> Cmd msg) -> model -> ( model, Cmd msg )
withCmdIf condition createCmd model =
    if condition then
        withCmd createCmd model
    else
        ( model, Cmd.none )


withoutCmd : model -> ( model, Cmd msg )
withoutCmd model =
    ( model, Cmd.none )


addCmd : (model -> Cmd msg) -> ( model, Cmd msg ) -> ( model, Cmd msg )
addCmd createCmd ( model, cmd ) =
    ( model, Cmd.batch [ cmd, createCmd model ] )
