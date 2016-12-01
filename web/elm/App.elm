module App exposing (..)
import Html.Attributes exposing (..)

import Html exposing (..)

main : Html msg
main =
  div [class "title"] [ 
    h1 [] [text "Cotoami☺"], 
    p [] [
      text "Developing at ",
      a [href "https://github.com/cotoami", target "_blank"] [
        text "https://github.com/cotoami"
      ]
    ]
  ]
