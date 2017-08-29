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
        |> Maybe.map (\coto ->
            modalConfig model.connectingOutbound (getSelectedCotos model) coto
        )
        |> Modal.view "connect-modal"


modalConfig : Bool -> List Coto -> Coto -> Modal.Config Msg
modalConfig outbound selectedCotos connectingCoto =
    { closeMessage = CloseConnectModal
    , title = "Connect Preview"
    , content = modalContent outbound selectedCotos connectingCoto
    , buttons =
        [ button
            [ class "button button-primary"
            , onClick (Connect outbound connectingCoto selectedCotos)
            ]
            [ text "Connect" ]
        ]
    }


modalContent : Bool -> List Coto -> Coto -> Html Msg
modalContent outbound selectedCotos connectingCoto =
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
            if outbound then
                ( connectingCotoHtml, selectedCotosHtml )
            else
                ( selectedCotosHtml, connectingCotoHtml )

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
