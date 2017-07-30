module App.Types.MemberPresences exposing (..)

import Dict
import App.Types.Amishi exposing (AmishiId)

type alias MemberPresences = Dict.Dict AmishiId Int


isPresent : AmishiId -> MemberPresences -> Bool
isPresent amishiId memberPresences =
    (Dict.get amishiId memberPresences |> Maybe.withDefault 0) > 0
