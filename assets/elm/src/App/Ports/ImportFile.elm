port module App.Ports.ImportFile
    exposing
        ( selectImportFile
        , importFileContentRead
        )

import App.Types.Amishi exposing (Amishi)


port selectImportFile : () -> Cmd msg


type alias ImportFile =
    { content : String
    , valid : Bool
    , amishi : Maybe Amishi
    , cotos : Int
    , cotonomas : Int
    , connections : Int
    }


port importFileContentRead : (ImportFile -> msg) -> Sub msg
