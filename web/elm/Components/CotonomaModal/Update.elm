module Components.CotonomaModal.Update exposing (..)

import Utils exposing (validateEmail)
import App.Types exposing (Session, Cotonoma)
import App.Commands exposing (fetchAmishi)
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
            ( { model 
              | memberEmail = memberEmail
              , memberEmailValid = validateEmail memberEmail
              }
            , timeline
            , Cmd.none 
            )
            
        AddMember ->
            ( { model | membersLoading = True }
            , timeline
            , fetchAmishi AmishiFetched model.memberEmail
            )
            
        AmishiFetched (Ok amishi) ->
            ( addMember model (SignedUp amishi)
            , timeline
            , Cmd.none 
            )
            
        AmishiFetched (Err _) ->
            ( addMember model (NotYetSignedUp model.memberEmail)
            , timeline
            , Cmd.none 
            )
            
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
