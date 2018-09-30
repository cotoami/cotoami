port module App.Ports.ImportFile
    exposing
        ( selectImportFile
        , ImportFile
        , importFileContentRead
        )


port selectImportFile : () -> Cmd msg


type alias ImportFile =
    { fileName : String
    , content : String
    , valid : Bool
    , error : String
    , amishiAvatarUrl : String
    , amishiDisplayName : String
    , cotos : Int
    , cotonomas : Int
    , connections : Int
    }


port importFileContentRead : (ImportFile -> msg) -> Sub msg
