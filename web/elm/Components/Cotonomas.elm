module Components.Cotonomas exposing (..)

import Html exposing (..)
import Html.Keyed
import Html.Attributes exposing (..)
import App.Model exposing (Model)
import App.Messages exposing (Msg)


view : Model -> Html Msg
view model =
    Html.Keyed.node
        "div"
        [ id "cotonomas" ]
        (List.map 
            (\cotonoma -> 
                ( toString cotonoma.id
                , div [ class "coto-as-cotonoma" ]
                    [ a []
                        [ i [ class "material-icons" ] [ text "exit_to_app" ]
                        , span [ class "cotonoma-name" ] [ text cotonoma.name ]
                        ]
                    ]
                )
            ) 
            (List.reverse model.cotonomas)
        )
