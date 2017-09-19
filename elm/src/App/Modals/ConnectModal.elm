module App.Modals.ConnectModal exposing (..)

import Maybe exposing (andThen)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Html.Keyed
import Util.Modal as Modal
import App.Types.Coto exposing (Coto, CotoId)
import App.Types.Graph exposing (Direction(..))
import App.Messages exposing (..)
import App.Model exposing (..)
import App.Markdown


view : Model -> Html Msg
view model =
    model.connectingCotoId
        |> andThen (\cotoId -> getCoto cotoId model)
        |> Maybe.map (\coto ->
            modalConfig model.connectingDirection (getSelectedCotos model) coto
        )
        |> Modal.view "connect-modal"


modalConfig : Direction -> List Coto -> Coto -> Modal.Config Msg
modalConfig direction selectedCotos connectingCoto =
    { closeMessage = CloseModal
    , title = "Connect Preview"
    , content = modalContent direction selectedCotos connectingCoto
    , buttons =
        [ button
            [ class "button button-primary"
            , onClick (Connect connectingCoto selectedCotos direction)
            ]
            [ text "Connect" ]
        ]
    }


modalContent : Direction -> List Coto -> Coto -> Html Msg
modalContent direction selectedCotos connectingCoto =
    let
        selectedCotosHtml =
            Html.Keyed.node
                "div"
                [ class "selected-cotos" ]
                (List.map
                    (\coto ->
                        ( toString coto.id
                        , div [ class "coto-content" ]
                            [ App.Markdown.markdown coto.content ]
                        )
                    )
                    (List.reverse selectedCotos)
                )

        connectingCotoHtml =
            div [ class "connecting-coto coto-content" ]
                [ App.Markdown.markdown connectingCoto.content ]

        ( start, end ) =
            case direction of
                Outbound -> ( connectingCotoHtml, selectedCotosHtml )
                Inbound -> ( selectedCotosHtml, connectingCotoHtml )

    in
        div []
            [ div
                [ class "start" ]
                [ start ]
            , div
                [ class "arrow" ]
                [ i [ class "material-icons" ] [ text "arrow_downward" ] ]
            , div
                [ class "end" ]
                [ end ]
            ]
