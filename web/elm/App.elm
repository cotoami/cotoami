module App exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
-- import Html.Events exposing (onFocus)

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
        div [class "toolbar"] [
          button [class "button-primary", disabled True] [text "Post"]
        ],
        textarea[class "post"] []
      ]
    ]
  ]
