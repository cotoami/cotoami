module App.Modals.ConnectModal
    exposing
        ( ConnectingTarget(..)
        , Model
        , initModel
        , WithConnectModal
        , open
        , openWithPost
        , update
        , view
        )

import Maybe exposing (andThen)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Html.Keyed
import Util.Modal as Modal
import Util.HtmlUtil exposing (materialIcon)
import Util.UpdateUtil exposing (withCmd, withoutCmd, addCmd)
import App.Types.Coto exposing (Coto, CotoId)
import App.Types.Graph exposing (Direction(..))
import App.Messages as AppMsg
    exposing
        ( Msg
            ( CloseModal
            , Connect
            , PostAndConnectToSelection
            )
        )
import App.Modals.ConnectModalMsg as ConnectModalMsg exposing (Msg(..))
import App.Submodels.Context exposing (Context)
import App.Submodels.Modals exposing (Modal(ConnectModal), Modals)
import App.Commands
import App.Markdown


type ConnectingTarget
    = Coto Coto
    | NewPost String (Maybe String)


type alias Model =
    { target : ConnectingTarget
    , direction : Direction
    }


initModel : ConnectingTarget -> Direction -> Model
initModel target direction =
    { target = target
    , direction = direction
    }


type alias WithConnectModal a =
    { a | connectModal : Maybe Model }


open :
    Direction
    -> ConnectingTarget
    -> Modals (WithConnectModal a)
    -> ( Modals (WithConnectModal a), Cmd AppMsg.Msg )
open direction target model =
    { model | connectModal = Just (initModel target direction) }
        |> App.Submodels.Modals.openModal ConnectModal
        |> withCmd (\model -> App.Commands.focus "connect-modal-primary-button" AppMsg.NoOp)


openWithPost :
    Maybe String
    -> String
    -> Modals (WithConnectModal a)
    -> ( Modals (WithConnectModal a), Cmd AppMsg.Msg )
openWithPost summary content =
    open Inbound (NewPost content summary)


update : Context a -> ConnectModalMsg.Msg -> Model -> ( Model, Cmd AppMsg.Msg )
update context msg model =
    case msg of
        ReverseDirection ->
            { model
                | direction =
                    case model.direction of
                        Outbound ->
                            Inbound

                        Inbound ->
                            Outbound
            }
                |> withoutCmd


view : List Coto -> Maybe Model -> Html AppMsg.Msg
view cotos maybeModel =
    maybeModel
        |> Maybe.map (modalConfig cotos)
        |> Modal.view "connect-modal"


modalConfig : List Coto -> Model -> Modal.Config AppMsg.Msg
modalConfig selectedCotos model =
    let
        primaryButtonId =
            "connect-modal-primary-button"
    in
        { closeMessage = CloseModal
        , title = text "Connect Preview"
        , content = modalContent selectedCotos model
        , buttons =
            case model.target of
                Coto coto ->
                    [ button
                        [ id primaryButtonId
                        , class "button button-primary"
                        , autofocus True
                        , onClick (Connect coto selectedCotos model.direction)
                        ]
                        [ text "Connect" ]
                    ]

                NewPost content summary ->
                    [ button
                        [ id primaryButtonId
                        , class "button button-primary"
                        , autofocus True
                        , onClick (PostAndConnectToSelection content summary model.direction)
                        ]
                        [ text "Post and connect" ]
                    ]
        }


modalContent : List Coto -> Model -> Html AppMsg.Msg
modalContent selectedCotos model =
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
            case model.target of
                Coto coto ->
                    div [ class "target-coto coto-content" ]
                        [ contentDiv coto.summary coto.content ]

                NewPost content summary ->
                    div [ class "target-new-post coto-content" ]
                        [ contentDiv summary content ]

        ( start, end ) =
            case model.direction of
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
                    , onClick (AppMsg.ConnectModalMsg ReverseDirection)
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


contentDiv : Maybe String -> String -> Html AppMsg.Msg
contentDiv maybeSummary content =
    maybeSummary
        |> Maybe.map
            (\summary ->
                div [ class "coto-summary" ] [ text summary ]
            )
        |> Maybe.withDefault (App.Markdown.markdown content)
        |> (\contentDiv -> div [ class "coto-inner" ] [ contentDiv ])
