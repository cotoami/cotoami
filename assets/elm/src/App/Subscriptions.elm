module App.Subscriptions exposing (..)

import Keyboard exposing (..)
import Phoenix
import Phoenix.Socket as Socket exposing (Socket)
import App.Model exposing (Model)
import App.Messages exposing (..)
import App.Channels exposing (globalChannel, cotonomaChannel)
import App.Ports.Graph


socket : String -> String -> Socket Msg
socket token websocketUrl =
    Socket.init websocketUrl
        |> Socket.withParams [ ( "token", token ) ]


phoenixChannels : Model -> Sub Msg
phoenixChannels model =
    model.context.session
        |> Maybe.map
            (\session ->
                Phoenix.connect
                    (socket session.token session.websocketUrl)
                    (model.context.cotonoma
                        |> Maybe.map
                            (\cotonoma ->
                                [ globalChannel
                                , cotonomaChannel cotonoma.key
                                ]
                            )
                        |> Maybe.withDefault [ globalChannel ]
                    )
            )
        |> Maybe.withDefault Sub.none


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Keyboard.downs KeyDown
        , phoenixChannels model
        , App.Ports.Graph.nodeClicked OpenTraversal
        ]
