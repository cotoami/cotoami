module App.Server.Cotonoma exposing (..)

import Http
import Json.Decode as Decode
import Json.Encode as Encode
import Date
import App.Messages exposing (Msg(..))
import App.Server.Amishi exposing (decodeAmishi)
import App.Types.Coto exposing (Cotonoma, CotonomaKey)


decodeCotonoma : Decode.Decoder Cotonoma
decodeCotonoma =
    Decode.map7 Cotonoma
        (Decode.field "id" Decode.string)
        (Decode.field "key" Decode.string)
        (Decode.field "name" Decode.string)
        (Decode.field "pinned" Decode.bool)
        (Decode.field "coto_id" Decode.string)
        (Decode.maybe (Decode.field "owner" decodeAmishi))
        (Decode.field "updated_at" (Decode.map Date.fromTime Decode.float))


fetchCotonomas : Cmd Msg
fetchCotonomas =
    Http.send CotonomasFetched <|
        Http.get "/api/cotonomas" <|
            Decode.map2 (,)
                (Decode.field "pinned" (Decode.list decodeCotonoma))
                (Decode.field "recent" (Decode.list decodeCotonoma))


fetchSubCotonomas : Maybe Cotonoma -> Cmd Msg
fetchSubCotonomas maybeCotonoma =
    maybeCotonoma
        |> Maybe.map
            (\cotonoma ->
                Decode.list decodeCotonoma
                    |> Http.get ("/api/cotonomas/" ++ cotonoma.id ++ "/cotonomas")
                    |> Http.send SubCotonomasFetched
            )
        |> Maybe.withDefault Cmd.none


encodeCotonoma : String -> Maybe Cotonoma -> Int -> String -> Encode.Value
encodeCotonoma clientId maybeCotonoma postId name =
    Encode.object
        [ ( "clientId", Encode.string clientId )
        , ( "cotonoma"
          , (Encode.object
                [ ( "cotonoma_id"
                  , case maybeCotonoma of
                        Nothing ->
                            Encode.null

                        Just cotonoma ->
                            Encode.string cotonoma.id
                  )
                , ( "postId", Encode.int postId )
                , ( "name", Encode.string name )
                ]
            )
          )
        ]
