module App.Modals.ImportModal exposing (Model)


type RequestStatus
    = None
    | Approved
    | Rejected


type alias Model =
    { data : String
    , requestProcessing : Bool
    , requestStatus : RequestStatus
    }
