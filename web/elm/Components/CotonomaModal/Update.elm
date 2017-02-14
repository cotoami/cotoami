module Components.CotonomaModal.Update exposing (..)

import App.Types exposing (Session, Cotonoma)
import Components.Timeline.Model as Timeline
import Components.Timeline.Messages
import Components.Timeline.Update
import Components.Timeline.Commands exposing (scrollToBottom)
import Components.CotonomaModal.Model exposing (..)
import Components.CotonomaModal.Messages exposing (..)
import Components.CotonomaModal.Commands exposing (..)


update : Msg -> Maybe Cotonoma -> Timeline.Model -> Model -> ( Model, Timeline.Model, Cmd Msg )
update msg maybeCotonoma timeline model =
    case msg of
        NoOp ->
            ( model, timeline, Cmd.none )
            
        Close ->
            ( { model | open = False }, timeline, Cmd.none )
            
        NameInput content ->
            ( { model | name = content }, timeline, Cmd.none )
            
        MemberEmailInput memberEmail ->
            ( { model | memberEmail = memberEmail }, timeline, Cmd.none )
            
        AddMember ->
            ( { model | memberEmail = "", membersLoading = True }
            , timeline
            , Cmd.none 
            )
            
        AmishiFetched (Ok amishi) ->
            ( model, timeline, Cmd.none )
            
        AmishiFetched (Err _) ->
            ( model, timeline, Cmd.none )
            
        Post ->
            let
                postId = timeline.postIdCounter + 1
                defaultPost = Timeline.defaultPost
                newPost = 
                    { defaultPost
                    | postId = Just postId
                    , content = model.name
                    , postedIn = maybeCotonoma
                    , asCotonoma = True
                    }
            in
                ( { model 
                  | open = False
                  , name = "" 
                  }
                , { timeline 
                  | posts = newPost :: timeline.posts
                  , postIdCounter = postId
                  }
                , Cmd.batch
                    [ scrollToBottom NoOp
                    , postCotonoma maybeCotonoma postId model.name 
                    ]
                )
                
        Posted (Ok response) ->
            let
                ( newTimeline, _ ) =
                    Components.Timeline.Update.update 
                        (Components.Timeline.Messages.Posted (Ok response)) 
                        timeline 
                        maybeCotonoma 
                        False
            in
                ( model, newTimeline, Cmd.none )
          
        Posted (Err _) ->
            ( model, timeline, Cmd.none )
