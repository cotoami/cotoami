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
                Just baseCotoId -> Just (modalConfig baseCotoId model)
         else
            Nothing
        )


modalConfig : Int -> Model -> Modal.Config Msg
modalConfig baseCotoId model =
    let
        maybeBaseCoto = getCoto baseCotoId model
        targetCotos = 
            List.filterMap 
                (\cotoId -> getCoto cotoId model) 
                model.cotoSelection
    in
        { closeMessage = CloseConnectModal
        , title = "Connect cotos"
        , content = 
            case maybeBaseCoto of
                Nothing -> 
                    div [] [ text "Selected coto has been deleted." ]
                Just baseCoto ->
                    modalContent targetCotos baseCoto
        , buttons = []
        }


modalContent : List Coto -> Coto -> Html Msg
modalContent targetCotos baseCoto =
    div []
        [ div [ class "base-coto coto" ]
            [ App.Markdown.markdown baseCoto.content ]
        , div [ class "connect-buttons" ]
            [ button 
                [ class "button button-primary connect-downward"
                , onClick (Connect False baseCoto targetCotos)
                ] 
                [ i [ class "material-icons" ] [ text "arrow_downward" ] ]
            , button 
                [ class "button button-primary connect-upward"
                , onClick (Connect True baseCoto targetCotos)
                ] 
                [ i [ class "material-icons" ] [ text "arrow_upward" ] ]
            ]
        , Html.Keyed.node
            "div"
            [ class "target-cotos" ]
            (List.map 
                (\coto ->
                    ( toString coto.id
                    , div [ class "coto" ] 
                        [ App.Markdown.markdown coto.content ]
                    )
                ) 
                (List.reverse targetCotos)
            )
        ]
