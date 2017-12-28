module App.Pushed exposing (..)

import Json.Encode exposing (Value)
import Json.Decode as Decode
import App.Types.Post exposing (Post)
import App.Model exposing (Model)
import App.Messages exposing (Msg(..))
import App.Commands
import App.Channels exposing (Payload)


type alias Handler body =
    Payload body -> Model -> ( Model, Cmd Msg )


handle : String -> Decode.Decoder body -> Handler body -> Value -> Model -> ( Model, Cmd Msg )
handle bodyName payloadDecoder handler payload model =
    case Decode.decodeValue (App.Channels.decodePayload bodyName payloadDecoder) payload of
        Ok decodedPayload ->
            if decodedPayload.clientId /= model.context.clientId then
                handler decodedPayload model
            else
                ( model, Cmd.none )

        Err err ->
            ( model, Cmd.none )


handlePost : Payload Post -> Model -> ( Model, Cmd Msg )
handlePost payload model =
    (model.timeline
        |> (\timeline -> ( timeline, payload.body :: timeline.posts ))
        |> (\( timeline, posts ) -> { timeline | posts = posts })
        |> (\timeline -> { model | timeline = timeline })
    )
        ! if payload.body.asCotonoma then
            [ App.Commands.scrollTimelineToBottom NoOp
            , App.Commands.sendMsg (CotonomaPushed payload.body)
            ]
          else
            [ App.Commands.scrollTimelineToBottom NoOp ]
