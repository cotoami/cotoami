module App exposing (..)
import Html.Attributes exposing (..)

import Html exposing (..)

main : Html msg
main =
  div [id "app", class "container"] [ 
    div [id "timeline-column"] [
      div [id "timeline"] [
        div [class "post"] [
          text "Hello"
        ],
        div [class "post"] [
          text "Bye"
        ]
      ],
      div [id "new-post"] [
        textarea[] []
      ]
    ]
  ]
