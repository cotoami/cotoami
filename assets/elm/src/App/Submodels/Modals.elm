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
        )

import App.Messages exposing (Msg(NoOp))


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
