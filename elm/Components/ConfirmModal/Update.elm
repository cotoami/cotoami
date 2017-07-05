module Components.ConfirmModal.Update exposing (..)

import Utils exposing (send)
import App.Messages
import Components.ConfirmModal.Model exposing (..)
import Components.ConfirmModal.Messages exposing (..)


update : Msg -> Model -> ( Model, Cmd App.Messages.Msg )
update msg model =
    case msg of
        Close ->
            ( { model | open = False }, Cmd.none )

        Confirm ->
            ( { model | open = False } , send model.msgOnConfirm )
