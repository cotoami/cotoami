module App.Update.Modal exposing
    ( openConnectModalByCoto
    , openConnectModalByNewPost
    , openConnectionModal
    , openCotoMenuModal
    , openCotoModal
    , openEditorModalForEdit
    , openEditorModalForNew
    , openImportModal
    , openInviteModal
    , openSigninModal
    )

import App.Commands
import App.Messages exposing (Msg)
import App.Modals.ConnectModal exposing (ConnectingTarget(..))
import App.Modals.ConnectionModal
import App.Modals.CotoMenuModal
import App.Modals.CotoModal
import App.Modals.EditorModal
import App.Modals.ImportModal
import App.Modals.InviteModal
import App.Modals.SigninModal
import App.Model exposing (Model)
import App.Ports.ImportFile exposing (ImportFile)
import App.Submodels.Context exposing (Context)
import App.Submodels.Modals exposing (Modal(..))
import App.Types.Connection exposing (Connection, Direction(..))
import App.Types.Coto exposing (Coto, CotoContent)
import App.Types.Session exposing (AuthSettings)
import Utils.UpdateUtil exposing (..)


openSigninModal : AuthSettings -> Model -> Model
openSigninModal authSettings model =
    { model | signinModal = App.Modals.SigninModal.initModel authSettings }
        |> App.Submodels.Modals.openModal SigninModal


openCotoMenuModal : Coto -> Model -> ( Model, Cmd Msg )
openCotoMenuModal coto model =
    { model | cotoMenuModal = Just (App.Modals.CotoMenuModal.initModel coto) }
        |> App.Submodels.Modals.openModal CotoMenuModal
        |> withCmd (\_ -> App.Modals.CotoMenuModal.sendInit)


openCotoModal : Coto -> Model -> Model
openCotoModal coto model =
    { model | cotoModal = Just (App.Modals.CotoModal.initModel coto) }
        |> App.Submodels.Modals.openModal CotoModal


openEditorModalForNew : Context context -> Maybe Coto -> Model -> ( Model, Cmd Msg )
openEditorModalForNew context source model =
    { model | editorModal = App.Modals.EditorModal.modelForNew context source }
        |> App.Submodels.Modals.openModal EditorModal
        |> withCmd (\_ -> App.Commands.focus "editor-modal-content-input" App.Messages.NoOp)


openEditorModalForEdit : Coto -> Model -> ( Model, Cmd Msg )
openEditorModalForEdit coto model =
    { model | editorModal = App.Modals.EditorModal.modelForEdit coto }
        |> App.Submodels.Modals.openModal EditorModal
        |> withCmd (\_ -> App.Commands.focus "editor-modal-content-input" App.Messages.NoOp)


openConnectModalByCoto : List Coto -> Coto -> Model -> ( Model, Cmd Msg )
openConnectModalByCoto selectedCotos coto model =
    openConnectModal selectedCotos Inbound (App.Modals.ConnectModal.Coto coto) model


openConnectModalByNewPost :
    Msg
    -> List Coto
    -> CotoContent
    -> Model
    -> ( Model, Cmd Msg )
openConnectModalByNewPost onPosted selectedCotos content model =
    model
        |> openConnectModal selectedCotos Inbound (NewPost content)
        |> Tuple.mapFirst
            (\({ connectModal } as model) ->
                { model | connectModal = { connectModal | onPosted = onPosted } }
            )


openConnectModal :
    List Coto
    -> Direction
    -> ConnectingTarget
    -> Model
    -> ( Model, Cmd Msg )
openConnectModal selectedCotos direction target model =
    { model
        | connectModal =
            App.Modals.ConnectModal.initModel
                target
                selectedCotos
                direction
    }
        |> App.Submodels.Modals.openModal ConnectModal
        |> withCmd
            (\_ ->
                App.Commands.focus
                    "connect-modal-primary-button"
                    App.Messages.NoOp
            )


openConnectionModal : Connection -> Coto -> Coto -> Model -> ( Model, Cmd Msg )
openConnectionModal connection startCoto endCoto model =
    let
        modal =
            App.Modals.ConnectionModal.initModel connection startCoto endCoto
    in
    { model | connectionModal = Just modal }
        |> App.Submodels.Modals.openModal ConnectionModal
        |> withCmd (\_ -> App.Modals.ConnectionModal.sendInit)


openImportModal : ImportFile -> Model -> Model
openImportModal importFile model =
    { model | importModal = Just (App.Modals.ImportModal.initModel importFile) }
        |> App.Submodels.Modals.openModal ImportModal


openInviteModal : Model -> ( Model, Cmd Msg )
openInviteModal model =
    { model | inviteModal = App.Modals.InviteModal.defaultModel }
        |> App.Submodels.Modals.openModal InviteModal
        |> withCmd (\_ -> App.Modals.InviteModal.sendInit)
