module App.Update exposing (..)

import Task
import Process
import Time
import Keys exposing (ctrl, meta, enter)
import App.Model exposing (..)
import App.Messages exposing (..)
import App.Commands exposing (fetchCotonoma, deleteCoto)
import Components.ConfirmModal.Update
import Components.SigninModal
import Components.ProfileModal
import Components.Timeline.Model 
    exposing (updatePost, toCoto, isPostedInCoto, isSelfOrPostedIn, setLoading)
import Components.Timeline.Messages
import Components.Timeline.Update
import Components.Timeline.Commands exposing (fetchPosts)
import Components.CotoModal
import Components.CotonomaModal


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            model ! []
            
        SessionFetched (Ok session) ->
            { model | session = Just session } ! []
            
        SessionFetched (Err _) ->
            model ! []
            
        HomeClick ->
            let
                timeline = model.timeline
            in
                { model | cotonoma = Nothing, timeline = setLoading timeline }
                    ! [ Cmd.map TimelineMsg fetchPosts ]
            
        CotonomaFetched (Ok (cotonoma, posts)) ->
            let
                ( timeline, cmd ) = 
                    Components.Timeline.Update.update 
                      (Components.Timeline.Messages.PostsFetched (Ok posts))
                      model.timeline
                      model.cotonoma
                      model.ctrlDown
            in
                { model 
                | cotonoma = Just cotonoma
                , timeline = timeline
                } 
                ! [ Cmd.map TimelineMsg cmd ]
            
        CotonomaFetched (Err _) ->
            model ! []
        
        KeyDown key ->
            if key == ctrl.keyCode || key == meta.keyCode then
                { model | ctrlDown = True } ! []
            else
                model ! []

        KeyUp key ->
            if key == ctrl.keyCode || key == meta.keyCode then
                { model | ctrlDown = False } ! []
            else
                model ! []
                
        ConfirmModalMsg subMsg ->
            let
                ( confirmModal, cmd ) = Components.ConfirmModal.Update.update subMsg model.confirmModal
            in
                { model | confirmModal = confirmModal } ! [ cmd ]
            
        OpenSigninModal ->
            let
                signinModal = model.signinModal
            in
                { model | signinModal = { signinModal | open = True } } ! []
            
        SigninModalMsg subMsg ->
            let
                ( signinModal, cmd ) = Components.SigninModal.update subMsg model.signinModal
            in
                { model | signinModal = signinModal } ! [ Cmd.map SigninModalMsg cmd ]
                
        OpenProfileModal ->
            let
                profileModal = model.profileModal
            in
                { model | profileModal = { profileModal | open = True } } ! []
                
        ProfileModalMsg subMsg ->
            let
                ( profileModal, cmd ) = Components.ProfileModal.update subMsg model.profileModal
            in
                { model | profileModal = profileModal } ! [ Cmd.map ProfileModalMsg cmd ]
                
        CotoModalMsg subMsg ->
            let
                ( cotoModal, cmd ) = Components.CotoModal.update subMsg model.cotoModal
                confirmModal = model.confirmModal
                timeline = model.timeline
                posts = timeline.posts
            in
                case subMsg of
                    Components.CotoModal.ConfirmDelete message ->
                        { model 
                        | cotoModal = cotoModal
                        , confirmModal =
                            { confirmModal
                            | open = True
                            , message = message
                            , msgOnConfirm = 
                                (case cotoModal.coto of
                                    Nothing -> App.Messages.NoOp
                                    Just coto -> CotoModalMsg (Components.CotoModal.Delete coto)
                                )
                            }
                        } !
                        [ Cmd.map CotoModalMsg cmd ]
                        
                    Components.CotoModal.Delete coto  -> 
                        { model 
                        | cotoModal = cotoModal
                        , timeline =
                            { timeline
                            | posts = posts |> List.map 
                                (\post -> 
                                    if isSelfOrPostedIn coto post then
                                        { post | beingDeleted = True }
                                    else
                                        post
                                )
                            }
                        } !
                        [ Cmd.map CotoModalMsg cmd
                        , deleteCoto coto.id
                        , Process.sleep (1 * Time.second)
                            |> Task.andThen (\_ -> Task.succeed ())
                            |> Task.perform (\_ -> DeleteCoto coto)
                        ]
                        
                    _ ->
                        { model | cotoModal = cotoModal } ! [ Cmd.map CotoModalMsg cmd ]
            
        TimelineMsg subMsg ->
            let
                ( timeline, cmd ) = 
                    Components.Timeline.Update.update 
                        subMsg 
                        model.timeline 
                        model.cotonoma
                        model.ctrlDown
                cotoModal = model.cotoModal
            in
                case subMsg of
                    Components.Timeline.Messages.PostClick cotoId ->
                        { model 
                        | timeline = timeline
                        , activeCotoId = (newActiveCotoId model.activeCotoId cotoId)
                        } ! [ Cmd.map TimelineMsg cmd ]
                        
                    Components.Timeline.Messages.PostOpen post ->
                        { model 
                        | timeline = timeline
                        , cotoModal = 
                            { cotoModal 
                            | open = True
                            , coto = toCoto post
                            }
                        } ! [ Cmd.map TimelineMsg cmd ]
                        
                    Components.Timeline.Messages.CotonomaClick key ->
                        { model | timeline = setLoading timeline } ! [ fetchCotonoma key ]

                    _ -> 
                        { model | timeline = timeline } ! [ Cmd.map TimelineMsg cmd ]
  
        DeleteCoto coto ->
            let
                timeline = model.timeline
                posts = timeline.posts
            in
                { model 
                | timeline =
                    { timeline
                    | posts = posts |> 
                        List.filter (\post -> not (isSelfOrPostedIn coto post))
                    }
                } ! []
                
        CotoDeleted _ ->
            model ! []
            
        OpenCotonomaModal ->
            let
                cotonomaModal = model.cotonomaModal
            in
                { model | cotonomaModal = { cotonomaModal | open = True } } ! []
                
        CotonomaModalMsg subMsg ->
            let
                ( cotonomaModal, timeline, cmd ) = 
                    Components.CotonomaModal.update 
                        subMsg
                        model.cotonoma
                        model.timeline
                        model.cotonomaModal
            in
                { model | cotonomaModal = cotonomaModal, timeline = timeline }
                    ! [ Cmd.map CotonomaModalMsg cmd ]


newActiveCotoId : Maybe Int -> Int -> Maybe Int
newActiveCotoId currentActiveId clickedId =
    case currentActiveId of
        Nothing -> Just clickedId
        Just activeId -> 
            if clickedId == activeId then
                Nothing
            else
                Just clickedId
            
