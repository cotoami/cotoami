module App.Subscriptions exposing (..)

import Keyboard exposing (..)
import Phoenix
import Phoenix.Socket as Socket exposing (Socket)
import App.Model exposing (Model)
import App.Messages exposing (..)
import App.Channels exposing (cotonomaChannel)


socket : String -> String -> Socket Msg
socket token websocketUrl =
    Socket.init websocketUrl
        |> Socket.withParams [ ( "token", token ) ]


phoenixChannels : Model -> Sub Msg
phoenixChannels model =
    case model.context.session of
        Nothing ->
            Sub.none

        Just session ->
            case model.context.cotonoma of
                Nothing ->
                    Sub.none

                Just cotonoma ->
                    Phoenix.connect
                        (socket session.token session.websocketUrl)
                        [ cotonomaChannel cotonoma.key ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Keyboard.downs KeyDown
        , Keyboard.ups KeyUp
        , phoenixChannels model
        ]
