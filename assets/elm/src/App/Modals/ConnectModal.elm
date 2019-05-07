module App.Modals.ConnectModal exposing
    ( ConnectingTarget(..)
    , Model
    , defaultModel
    , initModel
    , update
    , view
    )

import App.Commands
import App.I18n.Keys as I18nKeys
import App.Messages as AppMsg exposing (Msg(CloseModal))
import App.Modals.ConnectModalMsg as ModalMsg exposing (Msg(..))
import App.Server.Graph
import App.Server.Post
import App.Submodels.Context exposing (Context)
import App.Submodels.CotoSelection
import App.Submodels.LocalCotos exposing (LocalCotos)
import App.Types.Connection exposing (Direction(..))
import App.Types.Coto exposing (Coto, CotoContent, CotoId)
import App.Types.Post exposing (Post)
import App.Types.Timeline
import App.Update.Post
import App.Views.Connection
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Html.Keyed
import Maybe exposing (andThen)
import Utils.HtmlUtil
import Utils.Modal
import Utils.StringUtil
import Utils.UpdateUtil exposing (..)


type ConnectingTarget
    = None
    | Coto Coto
    | NewPost CotoContent


type alias Model =
    { target : ConnectingTarget
    , direction : Direction
    , linkingPhrase : String
    , onPosted : AppMsg.Msg
    }


defaultModel : Model
defaultModel =
    { target = None
    , direction = Inbound
    , linkingPhrase = ""
    , onPosted = AppMsg.NoOp
    }


initModel : ConnectingTarget -> Direction -> Model
initModel target direction =
    { defaultModel
        | target = target
        , direction = direction
    }


getLinkingPhrase : Model -> Maybe String
getLinkingPhrase model =
    if Utils.StringUtil.isBlank model.linkingPhrase then
        Nothing

    else
        Just model.linkingPhrase


view : Context context -> Model -> Html AppMsg.Msg
view context model =
    model
        |> modalConfig context
        |> Utils.Modal.view "connect-modal"


modalConfig : Context context -> Model -> Utils.Modal.Config AppMsg.Msg
modalConfig context model =
    let
        primaryButtonId =
            "connect-modal-primary-button"
    in
    { closeMessage = CloseModal
    , title = text (context.i18nText I18nKeys.ConnectModal_Title)
    , content = modalContent context model
    , buttons =
        case model.target of
            None ->
                []

            Coto coto ->
                [ button
                    [ id primaryButtonId
                    , class "button button-primary"
                    , autofocus True
                    , onClick (AppMsg.ConnectModalMsg (Connect coto))
                    ]
                    [ text (context.i18nText I18nKeys.ConnectModal_Connect) ]
                ]

            NewPost content ->
                [ button
                    [ id primaryButtonId
                    , class "button button-primary"
                    , autofocus True
                    , onClick
                        (AppMsg.ConnectModalMsg
                            (PostAndConnectToSelection content)
                        )
                    ]
                    [ text (context.i18nText I18nKeys.ConnectModal_PostAndConnect) ]
                ]
    }


modalContent : Context context -> Model -> Html AppMsg.Msg
modalContent context model =
    let
        selectedCotosHtml =
            context
                |> App.Submodels.CotoSelection.cotosInSelectedOrder
                |> List.map (\coto -> ( toString coto.id, App.Views.Connection.cotoDiv coto ))
                |> Html.Keyed.node "div" [ class "selected-cotos" ]

        targetHtml =
            case model.target of
                None ->
                    Utils.HtmlUtil.none

                Coto coto ->
                    div [ class "target-coto" ]
                        [ App.Views.Connection.cotoDiv coto ]

                NewPost content ->
                    div [ class "target-new-post" ]
                        [ App.Views.Connection.cotoContentDiv content.summary content.content ]

        ( start, end ) =
            case model.direction of
                Outbound ->
                    ( targetHtml, selectedCotosHtml )

                Inbound ->
                    ( selectedCotosHtml, targetHtml )
    in
    div [ id "connection" ]
        [ div
            [ class "tools" ]
            [ button
                [ class "button reverse-direction"
                , onClick (AppMsg.ConnectModalMsg ReverseDirection)
                ]
                [ text (context.i18nText I18nKeys.ConnectModal_Reverse) ]
            ]
        , div
            [ class "start" ]
            [ span [ class "node-title" ] [ text "From:" ]
            , start
            ]
        , App.Views.Connection.linkingPhraseInputDiv
            context
            (AppMsg.ConnectModalMsg << LinkingPhraseInput)
            Nothing
        , div
            [ class "end" ]
            [ span [ class "node-title" ] [ text "To:" ]
            , end
            ]
        ]


type alias UpdateModel model =
    LocalCotos { model | connectModal : Model }


update : Context context -> ModalMsg.Msg -> UpdateModel model -> ( UpdateModel model, Cmd AppMsg.Msg )
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

        LinkingPhraseInput input ->
            { model | connectModal = { connectModal | linkingPhrase = input } }
                |> withoutCmd

        Connect target ->
            let
                selectedCotos =
                    App.Submodels.CotoSelection.cotosInSelectedOrder context
            in
            App.Submodels.LocalCotos.connect
                context.session
                target
                selectedCotos
                model.connectModal.direction
                (getLinkingPhrase model.connectModal)
                model
                |> withCmd
                    (\model ->
                        App.Server.Graph.connect
                            context.clientId
                            (Maybe.map .key model.cotonoma)
                            target.id
                            (List.map .id selectedCotos)
                            model.connectModal.direction
                            (getLinkingPhrase model.connectModal)
                    )
                |> addCmd (\_ -> App.Commands.sendMsg AppMsg.CloseActiveModal)

        PostAndConnectToSelection content ->
            postAndConnectToSelection context content model
                |> addCmd (\_ -> App.Commands.sendMsg AppMsg.CloseActiveModal)

        PostedAndConnectToSelection postId (Ok post) ->
            App.Update.Post.onPosted context postId post model
                |> chain (connectPostToSelection context post)
                |> addCmd (\_ -> App.Commands.sendMsg model.connectModal.onPosted)
                |> addCmd (\_ -> App.Commands.sendMsg AppMsg.ClearModals)

        PostedAndConnectToSelection postId (Err _) ->
            model |> withoutCmd


postAndConnectToSelection :
    Context context
    -> CotoContent
    -> UpdateModel model
    -> ( UpdateModel model, Cmd AppMsg.Msg )
postAndConnectToSelection context content model =
    let
        ( newTimeline, newPost ) =
            App.Types.Timeline.post context False content model.timeline

        tag =
            AppMsg.ConnectModalMsg
                << PostedAndConnectToSelection newTimeline.postIdCounter
    in
    { model | timeline = newTimeline }
        |> withCmds
            (\model ->
                [ App.Commands.scrollTimelineToBottom (\_ -> AppMsg.NoOp)
                , App.Server.Post.post context.clientId context.cotonoma tag newPost
                ]
            )


connectPostToSelection :
    Context context
    -> Post
    -> UpdateModel model
    -> ( UpdateModel model, Cmd AppMsg.Msg )
connectPostToSelection context post model =
    post.cotoId
        |> Maybe.andThen (\cotoId -> App.Submodels.LocalCotos.getCoto cotoId model)
        |> Maybe.map
            (\target ->
                let
                    objects =
                        App.Submodels.CotoSelection.cotosInSelectedOrder context
                in
                ( App.Submodels.LocalCotos.connect
                    context.session
                    target
                    objects
                    model.connectModal.direction
                    (getLinkingPhrase model.connectModal)
                    model
                , App.Server.Graph.connect
                    context.clientId
                    (Maybe.map .key model.cotonoma)
                    target.id
                    (List.map .id objects)
                    model.connectModal.direction
                    (getLinkingPhrase model.connectModal)
                )
            )
        |> Maybe.withDefault ( model, Cmd.none )
