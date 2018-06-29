port module App.Ports.LocalStorage
    exposing
        ( setItem
        , getItem
        , getAllItems
        , clearStorage
        , receiveItem
        )

import Json.Encode as Encode


port setItem : ( String, Encode.Value ) -> Cmd msg


port getItem : String -> Cmd msg


port getAllItems : () -> Cmd msg


port clearStorage : Maybe String -> Cmd msg


port receiveItem : (( String, Encode.Value ) -> msg) -> Sub msg
