module Components.Cotonomas exposing (..)

import Html exposing (..)
import Html.Keyed
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Utils exposing (onClickWithoutPropagation)
import App.Types exposing (Cotonoma)
import App.Messages exposing (Msg(CotonomaClick))


view : List Cotonoma -> Html Msg
view cotonomas =
    Html.Keyed.node
        "div"
        [ class "cotonomas" ]
        (List.map
            (\cotonoma ->
                ( toString cotonoma.id
                , div [ class "coto-as-cotonoma" ]
                    [ a [ href ("/cotonomas/" ++ cotonoma.key)
                        , onClickWithoutPropagation (CotonomaClick cotonoma.key) ]
                        [ i [ class "material-icons" ] [ text "exit_to_app" ]
                        , span [ class "cotonoma-name" ] [ text cotonoma.name ]
                        ]
                    ]
                )
            )
            (List.reverse cotonomas)
        )
