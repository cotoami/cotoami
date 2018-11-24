module App.Subscriptions exposing (..)

import Keyboard exposing (..)
import Phoenix
import Phoenix.Socket as Socket exposing (Socket)
import App.Types.Session exposing (Session)
import App.Model exposing (Model)
import App.Messages exposing (..)
import App.Views.StockMsg
import App.Submodels.LocalCotos
import App.Channels
import App.Ports.LocalStorage
import App.Ports.Graph
import App.Ports.ImportFile


socket : String -> String -> Socket Msg
socket token websocketUrl =
    Socket.init websocketUrl
        |> Socket.withParams [ ( "token", token ) ]


phoenixChannels : Model -> Sub Msg
phoenixChannels model =
    model.session
        |> Maybe.map (phoenixChannelsInSession model)
        |> Maybe.withDefault Sub.none


phoenixChannelsInSession : Model -> Session -> Sub Msg
phoenixChannelsInSession model session =
    let
        channels =
            [ [ App.Channels.globalChannel ]
            , App.Channels.cotonomaChannels (App.Submodels.LocalCotos.getCotonomaKeysToWatch model)
            , App.Channels.cotoChannels (App.Submodels.LocalCotos.getCotoIdsToWatch model)
            , model.cotonoma
                |> Maybe.map (\cotonoma -> [ App.Channels.timelineChannel cotonoma.key ])
                |> Maybe.withDefault []
            ]
                |> List.concat
    in
        Phoenix.connect (socket session.token session.websocketUrl) channels


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Keyboard.downs KeyDown
        , phoenixChannels model
        , App.Ports.LocalStorage.receiveItem LocalStorageItemFetched
        , App.Ports.Graph.nodeClicked (StockMsg << App.Views.StockMsg.GraphNodeClicked)
        , App.Ports.ImportFile.importFileContentRead OpenImportModal
        ]
