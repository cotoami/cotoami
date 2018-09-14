module App.Modals.ConnectModal
    exposing
        ( ConnectingTarget(..)
        , Model
        , defaultModel
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
import Util.UpdateUtil exposing (..)
import App.Types.Coto exposing (Coto, CotoId, CotoContent)
import App.Types.Post exposing (Post)
import App.Types.Timeline
import App.Types.Graph exposing (Direction(..))
import App.Messages as AppMsg exposing (Msg(CloseModal))
import App.Modals.ConnectModalMsg as ConnectModalMsg exposing (Msg(..))
import App.Submodels.Context exposing (Context)
import App.Submodels.Modals exposing (Modal(ConnectModal), Modals)
import App.Submodels.LocalCotos exposing (LocalCotos)
import App.Commands
import App.Server.Post
import App.Server.Graph
import App.Markdown


type ConnectingTarget
    = None
    | Coto Coto
    | NewPost CotoContent


type alias Model =
    { target : ConnectingTarget
    , direction : Direction
    }


defaultModel : Model
defaultModel =
    { target = None
    , direction = Inbound
    }


initModel : ConnectingTarget -> Direction -> Model
initModel target direction =
    { target = target
    , direction = direction
    }


type alias WithConnectModal model =
    { model | connectModal : Model }


open :
    Direction
    -> ConnectingTarget
    -> Modals (WithConnectModal model)
    -> ( Modals (WithConnectModal model), Cmd AppMsg.Msg )
open direction target model =
    { model | connectModal = initModel target direction }
        |> App.Submodels.Modals.openModal ConnectModal
        |> withCmd (\model -> App.Commands.focus "connect-modal-primary-button" AppMsg.NoOp)


openWithPost :
    CotoContent
    -> Modals (WithConnectModal model)
    -> ( Modals (WithConnectModal model), Cmd AppMsg.Msg )
openWithPost content =
    open Inbound (NewPost content)


type alias UpdateModel model =
    LocalCotos (Modals (WithConnectModal model))


update : Context context -> ConnectModalMsg.Msg -> UpdateModel model -> ( UpdateModel model, Cmd AppMsg.Msg )
update context msg ({ connectModal } as model) =
    case msg of
        ReverseDirection ->
            let
                direction =
                    case connectModal.direction of
                        Outbound ->
                            Inbound

                        Inbound ->
                            Outbound
            in
                { model | connectModal = { connectModal | direction = direction } }
                    |> withoutCmd

        Connect target objects direction ->
            model
                |> App.Submodels.LocalCotos.connect context.session direction objects target
                |> App.Submodels.Modals.closeModal ConnectModal
                |> withCmd
                    (\model ->
                        App.Server.Graph.connect
                            context.clientId
                            (Maybe.map (\cotonoma -> cotonoma.key) model.cotonoma)
                            direction
                            (List.map (\coto -> coto.id) objects)
                            target.id
                    )

        PostAndConnectToSelection content direction ->
            model
                |> App.Submodels.Modals.closeModal ConnectModal
                |> postAndConnectToSelection context direction content

        PostedAndConnectToSelection postId direction (Ok response) ->
            { model | timeline = App.Types.Timeline.setCotoSaved postId response model.timeline }
                |> App.Submodels.Modals.clearModals
                |> connectPostToSelection context direction response

        PostedAndConnectToSelection postId direction (Err _) ->
            model |> withoutCmd


postAndConnectToSelection :
    Context context
    -> Direction
    -> CotoContent
    -> UpdateModel model
    -> ( UpdateModel model, Cmd AppMsg.Msg )
postAndConnectToSelection context direction content model =
    let
        ( newTimeline, newPost ) =
            App.Types.Timeline.post context False content model.timeline

        tag =
            (AppMsg.ConnectModalMsg
                << (PostedAndConnectToSelection newTimeline.postIdCounter direction)
            )
    in
        { model | timeline = newTimeline }
            |> withCmds
                (\model ->
                    [ App.Commands.scrollTimelineToBottom AppMsg.NoOp
                    , App.Server.Post.post context.clientId context.cotonoma tag newPost
                    ]
                )


connectPostToSelection :
    Context context
    -> Direction
    -> Post
    -> UpdateModel model
    -> ( UpdateModel model, Cmd AppMsg.Msg )
connectPostToSelection context direction post model =
    post.cotoId
        |> Maybe.andThen (\cotoId -> App.Submodels.LocalCotos.getCoto cotoId model)
        |> Maybe.map
            (\target ->
                let
                    objects =
                        App.Submodels.LocalCotos.getSelectedCotos context model

                    maybeCotonomaKey =
                        Maybe.map (\cotonoma -> cotonoma.key) model.cotonoma
                in
                    ( App.Submodels.LocalCotos.connect
                        context.session
                        direction
                        objects
                        target
                        model
                    , App.Server.Graph.connect
                        context.clientId
                        maybeCotonomaKey
                        direction
                        (List.map (\coto -> coto.id) objects)
                        target.id
                    )
            )
        |> Maybe.withDefault ( model, Cmd.none )


view : List Coto -> Model -> Html AppMsg.Msg
view cotos model =
    Modal.view "connect-modal" <| Just (modalConfig cotos model)


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
                None ->
                    []

                Coto coto ->
                    [ button
                        [ id primaryButtonId
                        , class "button button-primary"
                        , autofocus True
                        , onClick
                            (AppMsg.ConnectModalMsg
                                (Connect coto selectedCotos model.direction)
                            )
                        ]
                        [ text "Connect" ]
                    ]

                NewPost content ->
                    [ button
                        [ id primaryButtonId
                        , class "button button-primary"
                        , autofocus True
                        , onClick
                            (AppMsg.ConnectModalMsg
                                (PostAndConnectToSelection content model.direction)
                            )
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
                None ->
                    div [] []

                Coto coto ->
                    div [ class "target-coto coto-content" ]
                        [ contentDiv coto.summary coto.content ]

                NewPost content ->
                    div [ class "target-new-post coto-content" ]
                        [ contentDiv content.summary content.content ]

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
