module App.Submodels.Modals exposing
    ( Confirmation
    , Modal(..)
    , Modals
    , clearModals
    , closeActiveModal
    , closeModal
    , confirm
    , openModal
    )

import App.Messages exposing (Msg(NoOp))


type Modal
    = ConfirmModal
    | AppInfoModal
    | SigninModal
    | EditorModal
    | ProfileModal
    | InviteModal
    | CotoMenuModal
    | CotoModal
    | ConnectModal
    | ConnectionModal
    | ImportModal
    | TimelineFilterModal


type alias Modals a =
    { a
        | modals : List Modal
        , confirmation : Maybe Confirmation
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


type alias Confirmation =
    { message : String
    , msgOnConfirm : Msg
    }


confirm : Confirmation -> Modals a -> Modals a
confirm confirmation model =
    { model | confirmation = Just confirmation }
        |> openModal ConfirmModal
