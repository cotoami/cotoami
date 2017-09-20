module Components.CotonomaModal.Update exposing (..)

import Util.StringUtil exposing (validateEmail)
import App.Types.Context exposing (Context)
import App.Types.Session exposing (Session)
import App.Server.Amishi exposing (fetchAmishi)
import Components.CotonomaModal.Model exposing (..)
import Components.CotonomaModal.Messages exposing (..)


update : Msg -> Session -> Context -> Model -> ( Model, Cmd Msg )
update msg session context model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        NameInput content ->
            ( { model | name = content }, Cmd.none )

        MemberEmailInput memberEmail ->
            ( { model
              | memberEmail = memberEmail
              , memberEmailValid = validateEmail memberEmail
              }
            , Cmd.none
            )

        AddMember ->
            ( { model | membersLoading = True }
            , fetchAmishi AmishiFetched model.memberEmail
            )

        AmishiFetched (Ok amishi) ->
            ( addMember session (SignedUp amishi) model
            , Cmd.none
            )

        AmishiFetched (Err _) ->
            ( addMember session (NotYetSignedUp model.memberEmail) model
            , Cmd.none
            )

        RemoveMember email ->
            ( removeMember email model
            , Cmd.none
            )
