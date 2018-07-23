module App.Pushed exposing (..)

import Json.Encode exposing (Value)
import Json.Decode as Decode
import Util.HttpUtil exposing (ClientId(ClientId))
import App.Types.Coto exposing (Coto, CotoId, Cotonoma)
import App.Types.Post exposing (Post)
import App.Types.Graph
import App.Types.Timeline
import App.Model exposing (Model)
import App.Messages exposing (Msg(..))
import App.Commands
import App.Channels exposing (Payload)
import App.Server.Coto
import App.Server.Cotonoma


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
                    model.context.clientId
            in
                if senderId /= selfId then
                    handler decodedPayload model
                else
                    ( model, Cmd.none )

        Err err ->
            Debug.log err ( model, Cmd.none )


handleDelete : Payload CotoId -> Model -> ( Model, Cmd Msg )
handleDelete payload model =
    App.Model.getCoto payload.body model
        |> Maybe.map (\coto -> App.Model.deleteCoto coto model)
        |> Maybe.withDefault model
        |> \model -> ( model, Cmd.none )


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
    let
        -- Create the connection only if the start coto exists in the model
        graph1 =
            App.Model.getCoto payload.body.start.id model
                |> Maybe.map
                    (\startCoto ->
                        App.Types.Graph.connect
                            payload.amishi.id
                            startCoto
                            payload.body.end
                            model.graph
                    )
                |> Maybe.withDefault model.graph

        -- Do pinning if the start coto is the current cotonoma
        graph2 =
            model.context.cotonoma
                |> Maybe.andThen
                    (\cotonoma ->
                        if cotonoma.cotoId == payload.body.start.id then
                            Just <|
                                App.Types.Graph.pinCoto
                                    payload.amishi.id
                                    payload.body.end
                                    graph1
                        else
                            Nothing
                    )
                |> Maybe.withDefault graph1
    in
        ( { model | graph = graph2 }, Cmd.none )


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
            model.context.cotonoma
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
        ( { model | graph = graph2 }, Cmd.none )


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
            model.context.cotonoma
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
        ( { model | graph = graph2 }, Cmd.none )


handlePost : Payload Post -> Model -> ( Model, Cmd Msg )
handlePost payload model =
    ( { model | timeline = App.Types.Timeline.addPost payload.body model.timeline }
    , if payload.body.asCotonoma then
        Cmd.batch
            [ App.Commands.scrollTimelineToBottom NoOp
            , App.Server.Cotonoma.fetchCotonomas
            , App.Server.Cotonoma.fetchSubCotonomas model.context.cotonoma
            ]
      else
        App.Commands.scrollTimelineToBottom NoOp
    )


handleUpdate : Payload Coto -> Model -> ( Model, Cmd Msg )
handleUpdate payload model =
    model
        |> App.Model.updateCotoContent payload.body
        |> App.Model.updateRecentCotonomasByCoto payload.body
        |> \model -> ( model, Cmd.none )


handleCotonomatize : Payload Cotonoma -> Model -> ( Model, Cmd Msg )
handleCotonomatize payload model =
    ( App.Model.cotonomatize payload.body.cotoId (Just payload.body.key) model
    , Cmd.none
    )
