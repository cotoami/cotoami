module App.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Exts.Maybe exposing (isJust)
import App.Model exposing (..)
import App.Messages exposing (..)
import Components.AppHeader
import Components.Timeline
import Components.SigninModal

view : Model -> Html Msg
view model =
    div [ id "app" ]
        [ Components.AppHeader.view model
        , div [ id "app-body", class "container" ]
            [ Components.Timeline.view model
            ]
        , Html.map SigninModalMsg 
            (Components.SigninModal.view 
                model.signinModal
                ((isJust model.session) || (List.isEmpty model.cotos))
            )
        ]
