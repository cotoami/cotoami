module Components.ConnectModal exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Keyed
import Modal
import App.Types exposing (ConnectMode)
import App.Messages exposing (..)
import App.Model exposing (..)
import App.Markdown


view : Model -> Html Msg
view model =
    Modal.view
        "connect-modal"
        (if model.connectModalOpen then
            case model.connectMode of 
                Nothing -> Nothing
                Just connectMode -> Just (modalConfig connectMode model)
         else
            Nothing
        )


modalConfig : ConnectMode -> Model -> Modal.Config Msg
modalConfig connectMode model =
    let
        maybeBaseCoto = getCoto connectMode.baseCotoId model
        targetCotos = 
            List.filterMap 
                (\cotoId -> getCoto cotoId model) 
                connectMode.targetCotoIds
    in
        { closeMessage = CloseConnectModal
        , title = "Connect cotos"
        , content = div []
            [ case maybeBaseCoto of
                Nothing -> 
                    div [] [ text "Coto deleted" ]
                Just baseCoto ->
                    div [ class "base-coto coto" ]
                        [ App.Markdown.markdown baseCoto.content ]
            , div [ class "connect-buttons" ]
                [ button 
                    [ class "button button-primary connect-downward" ] 
                    [ i [ class "material-icons" ] [ text "arrow_downward" ] ]
                , button 
                    [ class "button button-primary connect-upward" ] 
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
        , buttons = []
        }
