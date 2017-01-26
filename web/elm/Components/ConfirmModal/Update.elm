module Components.ConfirmModal.Update exposing (..)

import Components.ConfirmModal.Model exposing (..)
import Components.ConfirmModal.Messages exposing (..)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Close ->
            ( { model | open = False }, Cmd.none )
