module Components.ConnectModal exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Html.Keyed
import Modal
import App.Types exposing (Coto)
import App.Messages exposing (..)
import App.Model exposing (..)
import App.Markdown


view : Model -> Html Msg
view model =
    Modal.view
        "connect-modal"
        (if model.connectModalOpen then
            case model.connectingTo of
                Nothing -> Nothing
                Just startCotoId -> Just (modalConfig startCotoId model)
         else
            Nothing
        )


modalConfig : Int -> Model -> Modal.Config Msg
modalConfig startCotoId model =
    let
        maybeStartCoto = getCoto startCotoId model
        endCotos = getSelectedCoto model
    in
        case maybeStartCoto of
            Nothing ->
                { closeMessage = CloseConnectModal
                , title = "Connect Preview"
                , content = div [] [ text "Selected coto has been deleted." ]
                , buttons = []
                }

            Just startCoto ->
                { closeMessage = CloseConnectModal
                , title = "Connect Preview"
                , content = modalContent startCoto endCotos
                , buttons =
                    [ button
                        [ class "button button-primary"
                        , onClick (Connect startCoto endCotos)
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
