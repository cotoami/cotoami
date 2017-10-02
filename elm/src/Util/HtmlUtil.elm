module Util.HtmlUtil exposing (faIcon, materialIcon)

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


materialIcon : String -> Maybe String -> Html msg
materialIcon name maybeAdditionalClass =
    i
        [ classList
            [ ( "material-icons", True )
            , case maybeAdditionalClass of
                Nothing ->
                    ( "", False )

                Just additionalClass ->
                    ( additionalClass, True )
            ]
        ]
        [ text name ]
