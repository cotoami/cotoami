module App.Submodels.Modals
    exposing
        ( Modal(..)
        , Confirmation
        , defaultConfirmation
        , Modals
        , openModal
        , closeActiveModal
        , closeModal
        , clearModals
        , confirm
        , maybeConfirm
        , confirmConnect
        , confirmPostAndConnect
        , openCotoMenu
        , openCoto
        )

import Util.UpdateUtil exposing (..)
import App.Messages exposing (Msg(NoOp))
import App.Commands
import App.Types.Coto exposing (Coto)
import App.Types.Graph exposing (Direction(..))
import App.Modals.ConnectModal exposing (ConnectingTarget(..))
import App.Modals.CotoMenuModal
import App.Modals.CotoModal


type Modal
    = ConfirmModal
    | SigninModal
    | EditorModal
    | ProfileModal
    | InviteModal
    | CotoMenuModal
    | CotoModal
    | ConnectModal
    | ImportModal
    | TimelineFilterModal


type alias Confirmation =
    { message : String
    , msgOnConfirm : Msg
    }


defaultConfirmation : Confirmation
defaultConfirmation =
    { message = ""
    , msgOnConfirm = App.Messages.NoOp
    }


type alias Modals a =
    { a
        | modals : List Modal
        , confirmation : Confirmation
        , connectModal : Maybe App.Modals.ConnectModal.Model
        , cotoMenuModal : Maybe App.Modals.CotoMenuModal.Model
        , cotoModal : Maybe App.Modals.CotoModal.Model
    }


openModal : Modal -> Modals a -> Modals a
openModal modal model =
    if List.member modal model.modals then
        model
    else
        { model | modals = modal :: model.modals }


closeActiveModal : Modals a -> Modals a
closeActiveModal model =
    { model | modals = Maybe.withDefault [] (List.tail model.modals) }


closeModal : Modal -> Modals a -> Modals a
closeModal modal model =
    { model | modals = List.filter (\m -> m /= modal) model.modals }


clearModals : Modals a -> Modals a
clearModals model =
    { model | modals = [] }


confirm : Confirmation -> Modals a -> Modals a
confirm confirmation model =
    { model | confirmation = confirmation }
        |> openModal ConfirmModal


maybeConfirm : Maybe Confirmation -> Modals a -> Modals a
maybeConfirm maybeConfirmation model =
    maybeConfirmation
        |> Maybe.map (\confirmation -> confirm confirmation model)
        |> Maybe.withDefault model


confirmConnect : Direction -> ConnectingTarget -> Modals a -> Modals a
confirmConnect direction target model =
    let
        connectModal =
            App.Modals.ConnectModal.initModel target direction
    in
        { model | connectModal = Just connectModal }
            |> openModal ConnectModal


confirmPostAndConnect : Maybe String -> String -> Modals a -> ( Modals a, Cmd Msg )
confirmPostAndConnect summary content model =
    model
        |> confirmConnect Inbound (NewPost content summary)
        |> withCmd (\model -> App.Commands.focus "connect-modal-primary-button" NoOp)


openCotoMenu : Coto -> Modals a -> Modals a
openCotoMenu coto model =
    coto
        |> App.Modals.CotoMenuModal.initModel
        |> (\modal -> { model | cotoMenuModal = Just modal })
        |> openModal CotoMenuModal


openCoto : Coto -> Modals a -> Modals a
openCoto coto model =
    coto
        |> App.Modals.CotoModal.initModel
        |> (\modal -> { model | cotoModal = Just modal })
        |> openModal CotoModal
