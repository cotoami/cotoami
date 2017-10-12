module App.Types.Amishi exposing (..)

import Dict exposing (Dict)

type alias AmishiId = String


type alias Amishi =
    { id : AmishiId
    , email : String
    , owner : Bool
    , avatarUrl : String
    , displayName : String
    }


type alias Presences = Dict AmishiId Int


isPresent : AmishiId -> Presences -> Bool
isPresent amishiId presences =
    (Dict.get amishiId presences |> Maybe.withDefault 0) > 0
