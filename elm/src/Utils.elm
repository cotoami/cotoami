module Utils exposing
    ( send
    , httpRequestWithBody
    , httpDelete
    , httpPost
    , httpPut
    )

import Task
import Http
import Json.Decode as Decode


-- https://medium.com/elm-shorts/how-to-turn-a-msg-into-a-cmd-msg-in-elm-5dd095175d84
send : msg -> Cmd msg
send msg =
    Task.succeed msg |> Task.perform identity


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
