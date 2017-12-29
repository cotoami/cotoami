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
            ( model, Cmd.none )


handleUpdate : Payload Coto -> Model -> ( Model, Cmd Msg )
handleUpdate payload model =
    model
        |> App.Model.updateCotoContent payload.body
        |> App.Model.updateRecentCotonomasByCoto payload.body
        |> \model -> ( model, Cmd.none )


handleDelete : Payload CotoId -> Model -> ( Model, Cmd Msg )
handleDelete payload model =
    App.Model.getCoto payload.body model
        |> Maybe.map (\coto -> App.Model.deleteCoto coto model)
        |> Maybe.withDefault model
        |> \model -> ( model, Cmd.none )


handleCotonoma : Payload Cotonoma -> Model -> ( Model, Cmd Msg )
handleCotonoma payload model =
    ( App.Model.updateRecentCotonomas payload.body model
    , Cmd.none
    )


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


handlePin : Payload CotoId -> Model -> ( Model, Cmd Msg )
handlePin payload model =
    App.Model.getCoto payload.body model
        |> Maybe.map
            (\coto ->
                { model
                    | graph =
                        App.Types.Graph.pinCoto
                            payload.amishi.id
                            coto
                            model.graph
                }
            )
        |> Maybe.withDefault model
        |> \model -> ( model, App.Commands.scrollPinnedCotosToBottom NoOp )


handleUnpin : Payload CotoId -> Model -> ( Model, Cmd Msg )
handleUnpin payload model =
    ( { model | graph = App.Types.Graph.unpinCoto payload.body model.graph }
    , Cmd.none
    )
