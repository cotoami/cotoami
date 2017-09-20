module App.Server.Cotonoma exposing (..)

import Http
import Json.Decode as Decode
import Json.Encode as Encode
import App.Messages exposing (Msg(..))
import App.Server.Amishi exposing (decodeAmishi)
import App.Types.Coto exposing (Cotonoma, CotonomaKey, Member(..))


decodeCotonoma : Decode.Decoder Cotonoma
decodeCotonoma =
    Decode.map5 Cotonoma
        (Decode.field "id" Decode.string)
        (Decode.field "key" Decode.string)
        (Decode.field "name" Decode.string)
        (Decode.field "coto_id" Decode.string)
        (Decode.maybe (Decode.field "owner" decodeAmishi))


fetchRecentCotonomas : Cmd Msg
fetchRecentCotonomas =
    Http.send RecentCotonomasFetched
        <| Http.get "/api/cotonomas"
        <| Decode.list decodeCotonoma


fetchSubCotonomas : Maybe Cotonoma -> Cmd Msg
fetchSubCotonomas maybeCotonoma =
    case maybeCotonoma of
        Nothing -> Cmd.none
        Just cotonoma ->
            Http.send SubCotonomasFetched
                <| Http.get ("/api/cotonomas?cotonoma_id=" ++ cotonoma.id)
                <| Decode.list decodeCotonoma


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
