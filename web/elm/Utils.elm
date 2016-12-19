module Utils exposing (..)

import String

isBlank : String -> Bool
isBlank string =
    String.trim string |> String.isEmpty
