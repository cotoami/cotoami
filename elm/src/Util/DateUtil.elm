module Util.DateUtil exposing (format, sameDay)

import Date exposing (Date, year, month, day)
import Date.Extra.Format
import Date.Extra.Config.Config_en_us as Config_en_us


format : String -> Date -> String
format format date =
    Date.Extra.Format.format Config_en_us.config format date


sameDay : Maybe Date -> Maybe Date -> Bool
sameDay date1 date2 =
    (Maybe.map2
        (\d1 d2 ->
            (year d1 == year d2) && (month d1 == month d2) && (day d1 == day d2)
        )
        date1
        date2
    )
        |> Maybe.withDefault False
