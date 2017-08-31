module App.Views.Cotonomas exposing (..)

import Html exposing (..)
import Html.Keyed
import Html.Attributes exposing (..)
import Util.EventUtil exposing (onLinkButtonClick)
import App.Types.Coto exposing (Cotonoma)
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
                    [ a
                        [ href ("/cotonomas/" ++ cotonoma.key)
                        , onLinkButtonClick (CotonomaClick cotonoma.key)
                        ]
                        [ i [ class "material-icons" ] [ text "exit_to_app" ]
                        , span [ class "cotonoma-name" ] [ text cotonoma.name ]
                        ]
                    ]
                )
            )
            cotonomas
        )
