module Components.CotonomaModal.Update exposing (..)

import Util.StringUtil exposing (validateEmail)
import App.Types.Context exposing (Context)
import App.Types.Session exposing (Session)
import App.Types.Timeline exposing (Timeline, postContent)
import App.Server.Amishi exposing (fetchAmishi)
import App.Commands exposing (scrollTimelineToBottom)
import Components.CotonomaModal.Model exposing (..)
import Components.CotonomaModal.Messages exposing (..)
import Components.CotonomaModal.Commands exposing (..)


update : Msg -> Session -> Context -> Timeline -> Model -> ( Model, Timeline, Cmd Msg )
update msg session context timeline model =
    case msg of
        NoOp ->
            ( model, timeline, Cmd.none )

        Close ->
            ( model, timeline, Cmd.none )

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
            timeline
                |> postContent context.clientId context.cotonoma True model.name
                |> \( timeline, _ ) ->
                    ( initModel
                    , timeline
                    , Cmd.batch
                        [ scrollTimelineToBottom NoOp
                        , postCotonoma
                            context.clientId
                            context.cotonoma
                            timeline.postIdCounter
                            model.members
                            model.name
                        ]
                    )

        Posted (Ok response) ->
            ( model, timeline, Cmd.none )

        Posted (Err _) ->
            ( model, timeline, Cmd.none )
