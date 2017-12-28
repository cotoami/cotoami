module Util.HttpUtil
    exposing
        ( ClientId(ClientId)
        , httpRequestWithBody
        , httpDelete
        , httpPost
        , httpPut
        )

import Http
import Json.Decode as Decode


type ClientId
    = ClientId String


commonRequestHeaders : ClientId -> List Http.Header
commonRequestHeaders (ClientId clientId) =
    [ Http.header "X-Requested-With" "XMLHttpRequest"
    , Http.header "X-Cotoami-ClientId" clientId
    ]


httpRequestWithBody : String -> String -> ClientId -> Http.Body -> Decode.Decoder a -> Http.Request a
httpRequestWithBody method url clientId body decoder =
    Http.request
        { method = method
        , headers = commonRequestHeaders clientId
        , url = url
        , body = body
        , expect = Http.expectJson decoder
        , timeout = Nothing
        , withCredentials = False
        }


httpDelete : String -> ClientId -> Http.Request String
httpDelete url clientId =
    Http.request
        { method = "DELETE"
        , headers = commonRequestHeaders clientId
        , url = url
        , body = Http.emptyBody
        , expect = Http.expectString
        , timeout = Nothing
        , withCredentials = False
        }


httpPost : String -> ClientId -> Http.Body -> Decode.Decoder a -> Http.Request a
httpPost =
    httpRequestWithBody "POST"


httpPut : String -> ClientId -> Http.Body -> Decode.Decoder a -> Http.Request a
httpPut =
    httpRequestWithBody "PUT"
