module Util.UpdateUtil exposing (withCmd, withoutCmd, addCmd)


withCmd : (model -> Cmd msg) -> model -> ( model, Cmd msg )
withCmd createCmd model =
    ( model, createCmd model )


withoutCmd : model -> ( model, Cmd msg )
withoutCmd model =
    ( model, Cmd.none )


addCmd : (model -> Cmd msg) -> ( model, Cmd msg ) -> ( model, Cmd msg )
addCmd createCmd ( model, cmd ) =
    ( model, Cmd.batch [ cmd, createCmd model ] )
