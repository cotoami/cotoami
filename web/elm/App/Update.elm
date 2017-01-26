module App.Update exposing (..)

import Keys exposing (ctrl, meta, enter)
import Exts.Maybe exposing (isJust, isNothing)
import App.Types exposing (Coto)
import App.Model exposing (..)
import App.Messages exposing (..)
import Components.SigninModal
import Components.ProfileModal
import Components.Timeline.Model
import Components.Timeline.Messages
import Components.Timeline.Update
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
                
        CotoModalMsg subMsg ->
            let
                ( cotoModal, cmd ) = Components.CotoModal.update subMsg model.cotoModal
            in
                ( { model | cotoModal = cotoModal }, Cmd.map CotoModalMsg cmd )
        
        TimelineMsg subMsg ->
            let
                clickedCotoId = 
                    (case subMsg of
                        Components.Timeline.Messages.CotoClick cotoId -> Just cotoId
                        _ -> Nothing
                    )
                openCoto =
                    (case subMsg of
                        Components.Timeline.Messages.CotoOpen coto -> Just coto
                        _ -> Nothing
                    )
                cotoModal = model.cotoModal
                ( timeline, cmd ) = Components.Timeline.Update.update subMsg model.timeline model.ctrlDown
            in
                ( { model 
                  | timeline = timeline
                  , activeCotoId = (newActiveCotoId model.activeCotoId clickedCotoId)
                  , cotoModal = 
                      { cotoModal 
                      | open = isJust openCoto
                      , coto = toCoto openCoto
                      }
                  }
                , Cmd.map TimelineMsg cmd 
                )


toCoto : Maybe Components.Timeline.Model.Coto -> Maybe Coto
toCoto timelineCoto =
    case timelineCoto of
        Nothing -> Nothing
        Just coto ->
            (case coto.id of
                Nothing -> Nothing
                Just cotoId -> Just (Coto cotoId coto.content)
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
                
    
    
