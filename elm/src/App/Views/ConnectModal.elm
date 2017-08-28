module App.Views.ConnectModal exposing (..)

import Maybe exposing (andThen)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Html.Keyed
import Modal
import App.Types.Coto exposing (Coto, CotoId)
import App.Messages exposing (..)
import App.Model exposing (..)
import App.Markdown


view : Model -> Html Msg
view model =
    model.connectingCotoId
        |> andThen (\cotoId -> getCoto cotoId model)
        |> modalConfig (getSelectedCotos model)
        |> Just
        |> Modal.view "connect-modal"


modalConfig : List Coto -> Maybe Coto -> Modal.Config Msg
modalConfig selectedCotos maybeConnectingCoto =
    case maybeConnectingCoto of
        Nothing ->
            { closeMessage = CloseConnectModal
            , title = "Connect Preview"
            , content = div [] [ text "Selected coto has been deleted." ]
            , buttons = []
            }

        Just connectingCoto ->
            { closeMessage = CloseConnectModal
            , title = "Connect Preview"
            , content = modalContent connectingCoto selectedCotos
            , buttons =
                [ button
                    [ class "button button-primary"
                    , onClick (Connect connectingCoto selectedCotos)
                    ]
                    [ text "Connect" ]
                ]
            }


modalContent : Coto -> List Coto -> Html Msg
modalContent startCoto endCotos =
    div []
        [ div
            [ class "start-coto coto" ]
            [ App.Markdown.markdown startCoto.content ]
        , div
            [ class "connect-buttons" ]
            [ i [ class "material-icons" ] [ text "arrow_downward" ] ]
        , Html.Keyed.node
            "div"
            [ class "end-cotos" ]
            (List.map
                (\coto ->
                    ( toString coto.id
                    , div [ class "coto" ]
                        [ App.Markdown.markdown coto.content ]
                    )
                )
                (List.reverse endCotos)
            )
        ]
