module Utils.ListUtil exposing (findValue)


findValue : (element -> Maybe value) -> List element -> Maybe value
findValue toValue list =
    case list of
        [] ->
            Nothing

        first :: rest ->
            toValue first
                |> Maybe.map Just
                |> Maybe.withDefault (findValue toValue rest)
