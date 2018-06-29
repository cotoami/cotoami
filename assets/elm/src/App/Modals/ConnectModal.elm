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
import App.Messages
    exposing
        ( Msg
            ( CloseModal
            , ReverseDirection
            , Connect
            , PostAndConnectToSelection
            )
        )
import App.Model exposing (Model, ConnectingTarget(..))
import App.Markdown


view : Model -> Html Msg
view model =
    model.connectingTarget
        |> Maybe.map
            (\target ->
                modalConfig
                    model.connectingDirection
                    (App.Model.getSelectedCotos model)
                    target
            )
        |> Modal.view "connect-modal"


modalConfig : Direction -> List Coto -> ConnectingTarget -> Modal.Config Msg
modalConfig direction selectedCotos target =
    let
        primaryButtonId =
            "connect-modal-primary-button"
    in
        { closeMessage = CloseModal
        , title = text "Connect Preview"
        , content = modalContent direction selectedCotos target
        , buttons =
            case target of
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
                        , onClick (PostAndConnectToSelection content summary)
                        ]
                        [ text "Post and connect" ]
                    ]
        }


modalContent : Direction -> List Coto -> ConnectingTarget -> Html Msg
modalContent direction selectedCotos target =
    let
        selectedCotosHtml =
            Html.Keyed.node
                "div"
                [ class "selected-cotos" ]
                (List.map
                    (\coto ->
                        ( toString coto.id
                        , div [ class "coto-content" ]
                            [ contentDiv coto.summary coto.content ]
                        )
                    )
                    selectedCotos
                )

        targetHtml =
            case target of
                Coto coto ->
                    div [ class "target-coto coto-content" ]
                        [ contentDiv coto.summary coto.content ]

                NewPost content summary ->
                    div [ class "target-new-post coto-content" ]
                        [ contentDiv summary content ]

        ( start, end ) =
            case direction of
                Outbound ->
                    ( targetHtml, selectedCotosHtml )

                Inbound ->
                    ( selectedCotosHtml, targetHtml )
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
                [ span [ class "node-title" ] [ text "From:" ]
                , start
                ]
            , div
                [ class "arrow" ]
                [ materialIcon "arrow_downward" Nothing ]
            , div
                [ class "end" ]
                [ span [ class "node-title" ] [ text "To:" ]
                , end
                ]
            ]


contentDiv : Maybe String -> String -> Html Msg
contentDiv maybeSummary content =
    maybeSummary
        |> Maybe.map
            (\summary ->
                div [ class "coto-summary" ] [ text summary ]
            )
        |> Maybe.withDefault (App.Markdown.markdown content)
        |> (\contentDiv -> div [ class "coto-inner" ] [ contentDiv ])
