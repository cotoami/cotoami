module App.Types.Amishi exposing (..)

import Dict exposing (Dict)


type alias AmishiId =
    String


type alias Amishi =
    { id : AmishiId
    , email : String
    , owner : Bool
    , avatarUrl : String
    , displayName : String
    }


type alias Presences =
    Dict AmishiId Int


isPresent : AmishiId -> Presences -> Bool
isPresent amishiId presences =
    (Dict.get amishiId presences |> Maybe.withDefault 0) > 0


applyPresenceDiff : ( Presences, Presences ) -> Presences -> Presences
applyPresenceDiff ( joins, leaves ) presences =
    -- Join
    (Dict.foldl
        (\amishiId count presences ->
            Dict.update
                amishiId
                (\maybeValue ->
                    case maybeValue of
                        Nothing ->
                            Just count

                        Just value ->
                            Just (value + count)
                )
                presences
        )
        presences
        joins
    )
        |> \presences ->
            -- Leave
            Dict.foldl
                (\amishiId count presences ->
                    Dict.update
                        amishiId
                        (\maybeValue ->
                            case maybeValue of
                                Nothing ->
                                    Nothing

                                Just value ->
                                    Just (value - count)
                        )
                        presences
                )
                presences
                leaves
