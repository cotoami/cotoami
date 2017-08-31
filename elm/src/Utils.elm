module Utils exposing
    ( send
    , onClickWithoutPropagation
    , onLinkButtonClick
    , httpRequestWithBody
    , httpDelete
    , httpPost
    , httpPut
    )

import Task
import Html exposing (Attribute)
import Html.Events exposing (onWithOptions)
import Json.Decode as Decode
import Http


-- https://medium.com/elm-shorts/how-to-turn-a-msg-into-a-cmd-msg-in-elm-5dd095175d84
send : msg -> Cmd msg
send msg =
    Task.succeed msg
    |> Task.perform identity


onClickWithoutPropagation : msg -> Attribute msg
onClickWithoutPropagation message =
    onNoValueEvent "click" message
        { stopPropagation = True
        , preventDefault = False
        }


onLinkButtonClick : msg -> Attribute msg
onLinkButtonClick message =
    onNoValueEvent "click" message
        { stopPropagation = True
        , preventDefault = True
        }


onNoValueEvent : String -> msg -> Html.Events.Options -> Attribute msg
onNoValueEvent eventName message options =
    onWithOptions eventName options (Decode.succeed message)


commonRequestHeaders : List Http.Header
commonRequestHeaders =
    [ Http.header "X-Requested-With" "XMLHttpRequest"
    ]


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
httpDelete url =
    Http.request
        { method = "DELETE"
        , headers = commonRequestHeaders
        , url = url
        , body = Http.emptyBody
        , expect = Http.expectString
        , timeout = Nothing
        , withCredentials = False
        }


httpPost : String -> Http.Body -> Decode.Decoder a -> Http.Request a
httpPost = httpRequestWithBody "POST"


httpPut : String -> Http.Body -> Decode.Decoder a -> Http.Request a
httpPut = httpRequestWithBody "PUT"
