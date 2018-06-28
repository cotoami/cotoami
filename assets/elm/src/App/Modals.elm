module App.Modals
    exposing
        ( Modal(..)
        , openModal
        , closeActiveModal
        , closeModal
        , clearModals
        , confirm
        , maybeConfirm
        )

import App.Confirmation exposing (Confirmation)


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


type alias Model a =
    { a
        | modals : List Modal
        , confirmation : Confirmation
    }


openModal : Modal -> Model a -> Model a
openModal modal model =
    if List.member modal model.modals then
        model
    else
        { model | modals = modal :: model.modals }


closeActiveModal : Model a -> Model a
closeActiveModal model =
    { model | modals = Maybe.withDefault [] (List.tail model.modals) }


closeModal : Modal -> Model a -> Model a
closeModal modal model =
    { model | modals = List.filter (\m -> m /= modal) model.modals }


clearModals : Model a -> Model a
clearModals model =
    { model | modals = [] }


confirm : Confirmation -> Model a -> Model a
confirm confirmation model =
    { model | confirmation = confirmation }
        |> openModal ConfirmModal


maybeConfirm : Maybe Confirmation -> Model a -> Model a
maybeConfirm maybeConfirmation model =
    maybeConfirmation
        |> Maybe.map (\confirmation -> confirm confirmation model)
        |> Maybe.withDefault model
