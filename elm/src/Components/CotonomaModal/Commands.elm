module Components.CotonomaModal.Commands exposing (..)

import Json.Encode as Encode
import Http
import Util.HttpUtil exposing (httpPost)
import App.Types.Coto exposing (Cotonoma)
import App.Server.Coto exposing (decodePost)
import App.Messages exposing (Msg(CotonomaPosted))
import Components.CotonomaModal.Model exposing (..)


postCotonoma : String -> Maybe Cotonoma -> Int -> List Member -> String -> Cmd Msg
postCotonoma clientId maybeCotonoma postId members name =
    Http.send CotonomaPosted
        <| httpPost
            "/api/cotonomas"
            (Http.jsonBody (encodeCotonoma clientId maybeCotonoma postId members name))
            decodePost


encodeCotonoma : String -> Maybe Cotonoma -> Int -> List Member -> String -> Encode.Value
encodeCotonoma clientId maybeCotonoma postId members name =
    Encode.object
        [ ( "clientId", Encode.string clientId )
        , ( "cotonoma",
            (Encode.object
                [ ( "cotonoma_id"
                  , case maybeCotonoma of
                        Nothing -> Encode.null
                        Just cotonoma -> Encode.string cotonoma.id
                  )
                , ( "postId", Encode.int postId )
                , ( "name", Encode.string name )
                , ( "members"
                  , Encode.list (members |> List.map (\m -> encodeMember m))
                  )
                ]
            )
          )
        ]


encodeMember : Member -> Encode.Value
encodeMember member =
    Encode.object
        [ case member of
            SignedUp amishi ->
                ( "amishi_id", Encode.string amishi.id )
            NotYetSignedUp email ->
                ( "email", Encode.string email )
        ]
