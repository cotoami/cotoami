module App.Pushed exposing
    ( ConnectPayloadBody
    , DisconnectPayloadBody
    , Handler
    , ReorderPayloadBody
    , decodeConnectPayloadBody
    , decodeConnectionUpdatePayloadBody
    , decodeDisconnectPayloadBody
    , decodeReorderPayloadBody
    , handle
    , handleConnect
    , handleConnectionUpdate
    , handleCotoUpdate
    , handleCotonomaUpdate
    , handleCotonomatize
    , handleDelete
    , handleDisconnect
    , handlePost
    , handleReorder
    )

import App.Channels exposing (Payload)
import App.Commands
import App.Messages exposing (Msg(..))
import App.Model exposing (Model)
import App.Ports.App
import App.Server.Coto
import App.Server.Cotonoma
import App.Submodels.LocalCotos
import App.Types.Coto exposing (Coto, CotoId, Cotonoma)
import App.Types.Graph
import App.Types.Graph.Connect
import App.Types.Graph.Reorder
import App.Types.Post exposing (Post)
import App.Types.Timeline
import Exts.Maybe exposing (isJust)
import Json.Decode as Decode
import Json.Encode exposing (Value)
import Utils.HttpUtil exposing (ClientId(ClientId))
import Utils.UpdateUtil exposing (..)


type alias Handler body =
    Payload body -> Model -> ( Model, Cmd Msg )


handle : Decode.Decoder body -> Handler body -> Value -> Model -> ( Model, Cmd Msg )
handle payloadDecoder handler payload model =
    case Decode.decodeValue (App.Channels.decodePayload payloadDecoder) payload of
        Ok decodedPayload ->
            let
                (ClientId senderId) =
                    decodedPayload.clientId

                (ClientId selfId) =
                    model.clientId
            in
            if senderId /= selfId then
                handler decodedPayload model

            else
                model |> withoutCmd

        Err err ->
            Debug.log err ( model, Cmd.none )


handlePost : Payload Post -> Model -> ( Model, Cmd Msg )
handlePost payload model =
    { model | timeline = App.Types.Timeline.addPost payload.body model.timeline }
        |> withCmdIf
            (\_ -> isJust payload.body.asCotonoma)
            App.Server.Cotonoma.refreshCotonomaList
        |> addCmd (\_ -> App.Commands.scrollTimelineToBottom (\_ -> NoOp))


handleDelete : Payload CotoId -> Model -> ( Model, Cmd Msg )
handleDelete payload model =
    model
        |> App.Model.deleteCoto payload.body
        |> withCmd App.Server.Cotonoma.refreshCotonomaList
        |> addCmd (\_ -> App.Commands.sendMsg GraphChanged)


handleCotonomaUpdate : Payload Cotonoma -> Model -> ( Model, Cmd Msg )
handleCotonomaUpdate payload model =
    model
        |> App.Submodels.LocalCotos.updateCotonoma payload.body
        |> withCmd App.Ports.App.updateUnreadStateInTitle


handleCotoUpdate : Payload Coto -> Model -> ( Model, Cmd Msg )
handleCotoUpdate payload model =
    model
        |> App.Submodels.LocalCotos.updateCoto payload.body
        |> withCmdIf
            (\_ -> isJust payload.body.asCotonoma)
            App.Server.Cotonoma.refreshCotonomaList
        |> addCmd (\_ -> App.Commands.sendMsg GraphChanged)


handleCotonomatize : Payload Cotonoma -> Model -> ( Model, Cmd Msg )
handleCotonomatize payload model =
    App.Submodels.LocalCotos.cotonomatize payload.body payload.body.cotoId model
        |> withCmd App.Server.Cotonoma.refreshCotonomaList
        |> addCmd (\_ -> App.Commands.sendMsg GraphChanged)


type alias ConnectPayloadBody =
    { start : Coto
    , end : Coto
    , linkingPhrase : Maybe String
    }


decodeConnectPayloadBody : Decode.Decoder ConnectPayloadBody
decodeConnectPayloadBody =
    Decode.map3 ConnectPayloadBody
        (Decode.field "start" App.Server.Coto.decodeCoto)
        (Decode.field "end" App.Server.Coto.decodeCoto)
        (Decode.field "linking_phrase" (Decode.maybe Decode.string))


handleConnect : Payload ConnectPayloadBody -> Model -> ( Model, Cmd Msg )
handleConnect payload model =
    model.cotonoma
        |> Maybe.andThen
            (\cotonoma ->
                if cotonoma.cotoId == payload.body.start.id then
                    Just <|
                        App.Types.Graph.Connect.pin
                            payload.amishi.id
                            payload.body.end
                            payload.body.linkingPhrase
                            model.graph

                else
                    Nothing
            )
        |> Maybe.withDefault
            (App.Submodels.LocalCotos.getCoto payload.body.start.id model
                |> Maybe.map
                    (\startCoto ->
                        App.Types.Graph.Connect.connect
                            payload.amishi.id
                            startCoto
                            payload.body.end
                            payload.body.linkingPhrase
                            model.graph
                    )
                |> Maybe.withDefault model.graph
            )
        |> (\graph -> { model | graph = graph })
        |> withCmd (\_ -> App.Commands.sendMsg GraphChanged)


type alias DisconnectPayloadBody =
    { startId : CotoId
    , endId : CotoId
    }


decodeDisconnectPayloadBody : Decode.Decoder DisconnectPayloadBody
decodeDisconnectPayloadBody =
    Decode.map2 DisconnectPayloadBody
        (Decode.field "start_id" Decode.string)
        (Decode.field "end_id" Decode.string)


handleDisconnect : Payload DisconnectPayloadBody -> Model -> ( Model, Cmd Msg )
handleDisconnect payload model =
    let
        -- Delete the connection
        graph1 =
            App.Types.Graph.Connect.disconnect
                ( payload.body.startId, payload.body.endId )
                model.graph

        -- Do unpinning if the start coto is the current cotonoma
        graph2 =
            model.cotonoma
                |> Maybe.andThen
                    (\cotonoma ->
                        if cotonoma.cotoId == payload.body.startId then
                            Just <|
                                App.Types.Graph.Connect.unpin
                                    payload.body.endId
                                    graph1

                        else
                            Nothing
                    )
                |> Maybe.withDefault graph1
    in
    { model | graph = graph2 }
        |> withCmd (\_ -> App.Commands.sendMsg GraphChanged)


type alias ConnectionUpdatePayloadBody =
    { startId : CotoId
    , endId : CotoId
    , linkingPhrase : Maybe String
    }


decodeConnectionUpdatePayloadBody : Decode.Decoder ConnectionUpdatePayloadBody
decodeConnectionUpdatePayloadBody =
    Decode.map3 ConnectionUpdatePayloadBody
        (Decode.field "start_id" Decode.string)
        (Decode.field "end_id" Decode.string)
        (Decode.field "linking_phrase" (Decode.maybe Decode.string))


handleConnectionUpdate : Payload ConnectionUpdatePayloadBody -> Model -> ( Model, Cmd Msg )
handleConnectionUpdate payload model =
    let
        graph =
            model.graph
                |> App.Types.Graph.setLinkingPhrase
                    model.cotonoma
                    payload.body.startId
                    payload.body.endId
                    payload.body.linkingPhrase
    in
    { model | graph = graph }
        |> withCmd (\_ -> App.Commands.sendMsg GraphChanged)


type alias ReorderPayloadBody =
    { startId : CotoId
    , endIds : List CotoId
    }


decodeReorderPayloadBody : Decode.Decoder ReorderPayloadBody
decodeReorderPayloadBody =
    Decode.map2 ReorderPayloadBody
        (Decode.field "start_id" Decode.string)
        (Decode.field "end_ids" (Decode.list Decode.string))


handleReorder : Payload ReorderPayloadBody -> Model -> ( Model, Cmd Msg )
handleReorder payload model =
    let
        -- Reorder connections
        graph1 =
            App.Types.Graph.Reorder.byCotoId
                (Just payload.body.startId)
                payload.body.endIds
                model.graph

        -- Reorder pinned cotos if the start coto is the current cotonoma
        graph2 =
            model.cotonoma
                |> Maybe.andThen
                    (\cotonoma ->
                        if cotonoma.cotoId == payload.body.startId then
                            Just <|
                                App.Types.Graph.Reorder.byCotoId
                                    Nothing
                                    payload.body.endIds
                                    graph1

                        else
                            Nothing
                    )
                |> Maybe.withDefault graph1
    in
    { model | graph = graph2 } |> withoutCmd
