module App.Pushed exposing (..)

import Json.Encode exposing (Value)
import Json.Decode as Decode
import Exts.Maybe exposing (isJust)
import Utils.HttpUtil exposing (ClientId(ClientId))
import Utils.UpdateUtil exposing (..)
import App.Types.Coto exposing (Coto, CotoId, Cotonoma)
import App.Types.Post exposing (Post)
import App.Types.Graph
import App.Types.Timeline
import App.Messages exposing (Msg(..))
import App.Model exposing (Model)
import App.Submodels.LocalCotos
import App.Commands
import App.Commands.Cotonoma
import App.Channels exposing (Payload)
import App.Server.Coto


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
            App.Commands.Cotonoma.refreshCotonomaList
        |> addCmd (\_ -> App.Commands.scrollTimelineToBottom NoOp)


handleDelete : Payload CotoId -> Model -> ( Model, Cmd Msg )
handleDelete payload model =
    App.Submodels.LocalCotos.getCoto payload.body model
        |> Maybe.map (\coto -> App.Model.deleteCoto coto model)
        |> Maybe.withDefault model
        |> withCmd App.Commands.Cotonoma.refreshCotonomaList


handleUpdate : Payload Coto -> Model -> ( Model, Cmd Msg )
handleUpdate payload model =
    model
        |> App.Submodels.LocalCotos.updateCoto payload.body
        |> withCmdIf
            (\_ -> isJust payload.body.asCotonoma)
            App.Commands.Cotonoma.refreshCotonomaList


handleCotonomatize : Payload Cotonoma -> Model -> ( Model, Cmd Msg )
handleCotonomatize payload model =
    App.Submodels.LocalCotos.cotonomatize payload.body payload.body.cotoId model
        |> withCmd App.Commands.Cotonoma.refreshCotonomaList


type alias ConnectPayloadBody =
    { start : Coto
    , end : Coto
    }


decodeConnectPayloadBody : Decode.Decoder ConnectPayloadBody
decodeConnectPayloadBody =
    Decode.map2 ConnectPayloadBody
        (Decode.field "start" App.Server.Coto.decodeCoto)
        (Decode.field "end" App.Server.Coto.decodeCoto)


handleConnect : Payload ConnectPayloadBody -> Model -> ( Model, Cmd Msg )
handleConnect payload model =
    model.cotonoma
        |> Maybe.andThen
            (\cotonoma ->
                if cotonoma.cotoId == payload.body.start.id then
                    Just <|
                        App.Types.Graph.pinCoto
                            payload.amishi.id
                            payload.body.end
                            model.graph
                else
                    Nothing
            )
        |> Maybe.withDefault
            (App.Submodels.LocalCotos.getCoto payload.body.start.id model
                |> Maybe.map
                    (\startCoto ->
                        App.Types.Graph.connect
                            payload.amishi.id
                            startCoto
                            payload.body.end
                            model.graph
                    )
                |> Maybe.withDefault model.graph
            )
        |> (\graph -> { model | graph = graph })
        |> withoutCmd


type alias DisconnectPayloadBody =
    { startId : CotoId
    , endId : CotoId
    }


decodeDisconnectPayloadBody : Decode.Decoder DisconnectPayloadBody
decodeDisconnectPayloadBody =
    Decode.map2 DisconnectPayloadBody
        (Decode.field "startId" Decode.string)
        (Decode.field "endId" Decode.string)


handleDisconnect : Payload DisconnectPayloadBody -> Model -> ( Model, Cmd Msg )
handleDisconnect payload model =
    let
        -- Delete the connection
        graph1 =
            App.Types.Graph.disconnect
                ( payload.body.startId, payload.body.endId )
                model.graph

        -- Do unpinning if the start coto is the current cotonoma
        graph2 =
            model.cotonoma
                |> Maybe.andThen
                    (\cotonoma ->
                        if cotonoma.cotoId == payload.body.startId then
                            Just <|
                                App.Types.Graph.unpinCoto
                                    payload.body.endId
                                    graph1
                        else
                            Nothing
                    )
                |> Maybe.withDefault graph1
    in
        { model | graph = graph2 } |> withoutCmd


type alias ReorderPayloadBody =
    { startId : CotoId
    , endIds : List CotoId
    }


decodeReorderPayloadBody : Decode.Decoder ReorderPayloadBody
decodeReorderPayloadBody =
    Decode.map2 ReorderPayloadBody
        (Decode.field "startId" Decode.string)
        (Decode.field "endIds" (Decode.list Decode.string))


handleReorder : Payload ReorderPayloadBody -> Model -> ( Model, Cmd Msg )
handleReorder payload model =
    let
        -- Reorder connections
        graph1 =
            App.Types.Graph.reorder
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
                                App.Types.Graph.reorder
                                    Nothing
                                    payload.body.endIds
                                    graph1
                        else
                            Nothing
                    )
                |> Maybe.withDefault graph1
    in
        { model | graph = graph2 } |> withoutCmd
