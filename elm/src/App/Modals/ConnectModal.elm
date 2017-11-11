module App.Modals.ConnectModal exposing (view)

import Maybe exposing (andThen)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Html.Keyed
import Util.Modal as Modal
import Util.HtmlUtil exposing (materialIcon)
import App.Types.Coto exposing (Coto, CotoId)
import App.Types.Graph exposing (Direction(..))
import App.Messages exposing (..)
import App.Model exposing (..)
import App.Markdown


view : Model -> Html Msg
view model =
    model.connectingSubject
        |> Maybe.map
            (\subject ->
                modalConfig
                    model.connectingDirection
                    (getSelectedCotos model)
                    subject
            )
        |> Modal.view "connect-modal"


modalConfig : Direction -> List Coto -> ConnectingSubject -> Modal.Config Msg
modalConfig direction selectedCotos subject =
    let
        primaryButtonId =
            "connect-modal-primary-button"
    in
        { closeMessage = CloseModal
        , title = text "Connect Preview"
        , content = modalContent direction selectedCotos subject
        , buttons =
            case subject of
                Coto coto ->
                    [ button
                        [ id primaryButtonId
                        , class "button button-primary"
                        , autofocus True
                        , onClick (Connect coto selectedCotos direction)
                        ]
                        [ text "Connect" ]
                    ]

                NewPost content summary ->
                    [ button
                        [ id primaryButtonId
                        , class "button button-primary"
                        , autofocus True
                        , onClick (PostAndConnect content summary)
                        ]
                        [ text "Post and connect" ]
                    ]
        }


modalContent : Direction -> List Coto -> ConnectingSubject -> Html Msg
modalContent direction selectedCotos subject =
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

        subjectHtml =
            case subject of
                Coto coto ->
                    div [ class "connecting-coto coto-content" ]
                        [ App.Markdown.markdown coto.content ]

                NewPost content summary ->
                    div [ class "connecting-new-post coto-content" ]
                        [ App.Markdown.markdown content ]

        ( start, end ) =
            case direction of
                Outbound ->
                    ( subjectHtml, selectedCotosHtml )

                Inbound ->
                    ( selectedCotosHtml, subjectHtml )
    in
        div []
            [ div
                [ class "tools" ]
                [ button
                    [ class "button reverse-direction"
                    , onClick ReverseDirection
                    ]
                    [ text "Reverse" ]
                ]
            , div
                [ class "start" ]
                [ start ]
            , div
                [ class "arrow" ]
                [ materialIcon "arrow_downward" Nothing ]
            , div
                [ class "end" ]
                [ end ]
            ]
