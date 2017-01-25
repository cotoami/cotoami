module App.Update exposing (..)

import Keys exposing (ctrl, meta, enter)
import App.Model exposing (..)
import App.Messages exposing (..)
import Components.SigninModal
import Components.ProfileModal
import Components.Timeline
import Components.CotoModal


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
                
        OpenProfileModal ->
            let
                profileModal = model.profileModal
            in
                ( { model | profileModal = { profileModal | open = True } }, Cmd.none )
                
        ProfileModalMsg subMsg ->
            let
                ( profileModal, cmd ) = Components.ProfileModal.update subMsg model.profileModal
            in
                ( { model | profileModal = profileModal }, Cmd.map ProfileModalMsg cmd )
                
        OpenCotoModalMsg ->
            let
                cotoModal = model.cotoModal
            in
                ( { model | cotoModal = { cotoModal | open = True } }, Cmd.none )
                
        CotoModalMsg subMsg ->
            let
                ( cotoModal, cmd ) = Components.CotoModal.update subMsg model.cotoModal
            in
                ( { model | cotoModal = cotoModal }, Cmd.map CotoModalMsg cmd )
        
        TimelineMsg subMsg ->
            let
                clickedCotoId = 
                    (case subMsg of
                        Components.Timeline.CotoClick cotoId -> Just cotoId
                        _ -> Nothing
                    )
                ( timeline, cmd ) = Components.Timeline.update subMsg model.timeline model.ctrlDown
            in
                ( { model 
                  | timeline = timeline
                  , activeCotoId = (newActiveCotoId model.activeCotoId clickedCotoId)
                  }
                , Cmd.map TimelineMsg cmd 
                )


newActiveCotoId : Maybe Int -> Maybe Int -> Maybe Int
newActiveCotoId currentActiveId maybeClickedId =
    case maybeClickedId of
        Nothing -> currentActiveId
        Just clickedId ->
            case currentActiveId of
                Nothing -> Just clickedId
                Just activeId -> 
                    if clickedId == activeId then
                        Nothing
                    else
                        Just clickedId
                
    
    
