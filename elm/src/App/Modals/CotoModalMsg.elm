module App.Modals.CotoModalMsg exposing (Msg(..))


type Msg
    = Edit
    | EditorInput String
    | SummaryInput String
    | CancelEditing
    | Save
    | ConfirmCotonomatize
    | Cotonomatize
