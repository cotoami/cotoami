module Components.Navigation exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import App.Model exposing (Model)
import App.Messages exposing (Msg)
import Components.Cotonomas


view : Model -> List (Html Msg)
view model =
    [ div [ id "navigation-content" ]
        [ div [ class "navigation-title" ] [ text "Recent" ]
        , Components.Cotonomas.view model.cotonomas
        ]
    ]
