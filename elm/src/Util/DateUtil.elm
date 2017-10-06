module Util.DateUtil exposing (format)

import Date exposing (Date)
import Date.Extra.Format
import Date.Extra.Config.Config_en_us as Config_en_us


format : String -> Date -> String
format format date =
    Date.Extra.Format.format Config_en_us.config format date
