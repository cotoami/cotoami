module App.Route exposing (..)

import Navigation exposing (Location)
import UrlParser exposing (..)
import App.Types.Coto exposing (CotonomaKey)


type Route
    = HomeRoute
    | CotonomaRoute CotonomaKey
    | NotFoundRoute


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ map HomeRoute top
        , map CotonomaRoute (s "cotonomas" </> string)
        ]


parseLocation : Location -> Route
parseLocation location =
    case (parsePath matchers location) of
        Just route ->
            route

        Nothing ->
            NotFoundRoute
