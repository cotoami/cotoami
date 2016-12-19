module Utils exposing ( isBlank, validateEmail )

import String
import Regex exposing (Regex, caseInsensitive, regex, contains)

isBlank : String -> Bool
isBlank string =
    String.trim string |> String.isEmpty


validateEmail : String -> Bool
validateEmail string =
    not (isBlank string) && Regex.contains emailRegex string


emailRegex : Regex
emailRegex =
    "^[a-zA-Z0-9.!#$%&'*+\\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        |> regex
        |> caseInsensitive
    
