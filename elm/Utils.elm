module Utils exposing 
    ( isBlank
    , validateEmail
    , onClickWithoutPropagation
    , post
    , delete
    )

import String
import Regex exposing (Regex, caseInsensitive, regex, contains)
import Html exposing (Attribute)
import Html.Events exposing (onWithOptions)
import Json.Decode as Decode
import Http


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
    

onClickWithoutPropagation : msg -> Attribute msg
onClickWithoutPropagation message =
    let
        defaultOptions = Html.Events.defaultOptions
    in
        onWithOptions 
            "click"
            { defaultOptions | stopPropagation = True }
            (Decode.succeed message)


commonRequestHeaders : List Http.Header
commonRequestHeaders =
    [ Http.header "X-Requested-With" "XMLHttpRequest"
    ]
    

post : String -> Http.Body -> Decode.Decoder a -> Http.Request a
post url body decoder =
    Http.request
        { method = "POST"
        , headers = commonRequestHeaders
        , url = url
        , body = body
        , expect = Http.expectJson decoder
        , timeout = Nothing
        , withCredentials = False
        }
        
        
delete : String -> Http.Request String
delete url =
    Http.request
        { method = "DELETE"
        , headers = commonRequestHeaders
        , url = url
        , body = Http.emptyBody
        , expect = Http.expectString 
        , timeout = Nothing
        , withCredentials = False
        }
