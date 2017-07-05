module Components.CotonomaModal.Update exposing (..)

import Utils exposing (validateEmail)
import App.Types exposing (Context, Session, Cotonoma)
import App.Commands exposing (fetchAmishi)
import Components.Timeline.Model as Timeline
import Components.Timeline.Messages
import Components.Timeline.Update exposing (postContent)
import Components.Timeline.Commands exposing (scrollToBottom)
import Components.CotonomaModal.Model exposing (..)
import Components.CotonomaModal.Messages exposing (..)
import Components.CotonomaModal.Commands exposing (..)


update : Msg -> Session -> Context -> Timeline.Model -> Model -> ( Model, Timeline.Model, Cmd Msg )
update msg session context timeline model =
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
            ( addMember session (SignedUp amishi) model
            , timeline
            , Cmd.none
            )

        AmishiFetched (Err _) ->
            ( addMember session (NotYetSignedUp model.memberEmail) model
            , timeline
            , Cmd.none
            )

        RemoveMember email ->
            ( removeMember email model
            , timeline
            , Cmd.none
            )

        Post ->
            let
                ( newTimeline, _ ) =
                    postContent context.clientId context.cotonoma True model.name timeline
            in
                ( initModel
                , newTimeline
                , Cmd.batch
                    [ scrollToBottom NoOp
                    , postCotonoma
                        context.clientId
                        context.cotonoma
                        newTimeline.postIdCounter
                        model.members
                        model.name
                    ]
                )

        Posted (Ok response) ->
            let
                ( newTimeline, _ ) =
                    Components.Timeline.Update.update
                        context
                        (Components.Timeline.Messages.Posted (Ok response))
                        timeline
            in
                ( model, newTimeline, Cmd.none )

        Posted (Err _) ->
            ( model, timeline, Cmd.none )
