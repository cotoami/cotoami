module Utils.StringUtil exposing (isBlank, isNotBlank, validateEmail)

import Regex exposing (Regex, caseInsensitive, regex, contains)


isBlank : String -> Bool
isBlank string =
    String.trim string |> String.isEmpty


isNotBlank : String -> Bool
isNotBlank string =
    not (isBlank string)


validateEmail : String -> Bool
validateEmail string =
    isNotBlank string && Regex.contains emailRegex string


emailRegex : Regex
emailRegex =
    "^[a-zA-Z0-9.!#$%&'*+\\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        |> regex
        |> caseInsensitive
