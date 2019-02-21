module App.Update.Modal exposing
    ( openConnectModalByCoto
    , openConnectModalByNewPost
    , openCotoMenuModal
    , openCotoModal
    , openEditorModalForEdit
    , openEditorModalForNew
    , openImportModal
    )

import App.Commands
import App.Messages exposing (Msg)
import App.Modals.ConnectModal exposing (ConnectingTarget(..))
import App.Modals.CotoMenuModal
import App.Modals.CotoModal
import App.Modals.EditorModal
import App.Modals.ImportModal
import App.Model exposing (Model)
import App.Ports.ImportFile exposing (ImportFile)
import App.Submodels.Context exposing (Context)
import App.Submodels.Modals exposing (Modal(..))
import App.Types.Connection exposing (Direction(..))
import App.Types.Coto exposing (Coto, CotoContent)
import Utils.UpdateUtil exposing (..)


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


openImportModal : ImportFile -> Model -> Model
openImportModal importFile model =
    { model | importModal = Just (App.Modals.ImportModal.initModel importFile) }
        |> App.Submodels.Modals.openModal ImportModal
