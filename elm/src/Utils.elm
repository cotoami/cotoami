module Utils exposing
    ( isBlank
    , validateEmail
    , send
    , onClickWithoutPropagation
    , httpRequest
    , httpRequestWithBody
    , httpDelete
    , httpPost
    , httpPutWithoutBody
    )

import String
import Regex exposing (Regex, caseInsensitive, regex, contains)
import Task
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


-- https://medium.com/elm-shorts/how-to-turn-a-msg-into-a-cmd-msg-in-elm-5dd095175d84
send : msg -> Cmd msg
send msg =
    Task.succeed msg
    |> Task.perform identity


onClickWithoutPropagation : msg -> Attribute msg
onClickWithoutPropagation message =
    onWithoutPropagation "click" message


onWithoutPropagation : String -> msg -> Attribute msg
onWithoutPropagation eventName message =
    let
        defaultOptions = Html.Events.defaultOptions
    in
        onWithOptions
            eventName
            { defaultOptions | stopPropagation = True, preventDefault = True }
            (Decode.succeed message)


commonRequestHeaders : List Http.Header
commonRequestHeaders =
    [ Http.header "X-Requested-With" "XMLHttpRequest"
    ]


httpRequest : String -> String -> Http.Request String
httpRequest method url =
    Http.request
        { method = method
        , headers = commonRequestHeaders
        , url = url
        , body = Http.emptyBody
        , expect = Http.expectString
        , timeout = Nothing
        , withCredentials = False
        }


httpRequestWithBody : String -> String -> Http.Body -> Decode.Decoder a -> Http.Request a
httpRequestWithBody method url body decoder =
    Http.request
        { method = method
        , headers = commonRequestHeaders
        , url = url
        , body = body
        , expect = Http.expectJson decoder
        , timeout = Nothing
        , withCredentials = False
        }


httpDelete : String -> Http.Request String
httpDelete = httpRequest "DELETE"


httpPost : String -> Http.Body -> Decode.Decoder a -> Http.Request a
httpPost = httpRequestWithBody "POST"


httpPutWithoutBody : String -> Http.Request String
httpPutWithoutBody = httpRequest "PUT"
