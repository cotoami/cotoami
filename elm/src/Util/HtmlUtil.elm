module Util.HtmlUtil exposing (faIcon)

import Html exposing (..)
import Html.Attributes exposing (..)


faIcon : String -> Maybe String -> Html msg
faIcon name maybeAdditionalClass =
    i
        [ classList
            [ ( "fa", True )
            , ( "fa-" ++ name, True )
            , case maybeAdditionalClass of
                Nothing ->
                    ( "", False )

                Just additionalClass ->
                    ( additionalClass, True )
            ]
        , (attribute "aria-hidden" "true")
        ]
        []
