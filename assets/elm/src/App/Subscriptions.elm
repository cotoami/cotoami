module App.Subscriptions exposing (..)

import Keyboard exposing (..)
import Phoenix
import Phoenix.Socket as Socket exposing (Socket)
import App.Model exposing (Model)
import App.Messages exposing (..)
import App.Channels
import App.Ports.LocalStorage
import App.Ports.Graph
import App.Types.Session exposing (Session)


socket : String -> String -> Socket Msg
socket token websocketUrl =
    Socket.init websocketUrl
        |> Socket.withParams [ ( "token", token ) ]


phoenixChannels : Model -> Sub Msg
phoenixChannels model =
    model.context.session
        |> Maybe.map (phoenixChannelsInSession model)
        |> Maybe.withDefault Sub.none


phoenixChannelsInSession : Model -> Session -> Sub Msg
phoenixChannelsInSession model session =
    Phoenix.connect
        (socket session.token session.websocketUrl)
        (App.Channels.cotoChannels (App.Model.getCotoIds model)
            |> (::) App.Channels.globalChannel
            |> (\channels ->
                    model.context.cotonoma
                        |> Maybe.map
                            (\cotonoma ->
                                App.Channels.cotonomaChannel cotonoma.key :: channels
                            )
                        |> Maybe.withDefault channels
               )
        )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Keyboard.downs KeyDown
        , phoenixChannels model
        , App.Ports.LocalStorage.receiveItem LocalStorageItemFetched
        , App.Ports.Graph.nodeClicked OpenTraversal
        ]
