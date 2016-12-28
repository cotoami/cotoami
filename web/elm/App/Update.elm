module App.Update exposing (..)

import Keys exposing (ctrl, meta, enter)
import App.Model exposing (..)
import App.Messages exposing (..)
import Components.SigninModal
import Components.Timeline


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            model ! []
            
        SessionFetched (Ok session) ->
            ( { model | session = Just session }, Cmd.none )
            
        SessionFetched (Err _) ->
            ( model, Cmd.none )
        
        KeyDown key ->
            if key == ctrl.keyCode || key == meta.keyCode then
                ( { model | ctrlDown = True }, Cmd.none )
            else
                ( model, Cmd.none )

        KeyUp key ->
            if key == ctrl.keyCode || key == meta.keyCode then
                ( { model | ctrlDown = False }, Cmd.none )
            else
                ( model, Cmd.none )
            
        OpenSigninModal ->
            let
                signinModal = model.signinModal
            in
                ( { model | signinModal = { signinModal | open = True } }, Cmd.none )
            
        SigninModalMsg subMsg ->
            let
                ( signinModal, cmd ) = Components.SigninModal.update subMsg model.signinModal
            in
                ( { model | signinModal = signinModal }, Cmd.map SigninModalMsg cmd )
        
        TimelineMsg subMsg ->
            let
                ( timeline, cmd ) = Components.Timeline.update subMsg model.timeline model.ctrlDown
            in
                ( { model | timeline = timeline }, Cmd.map TimelineMsg cmd )
