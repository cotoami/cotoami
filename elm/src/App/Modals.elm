module App.Modals exposing (..)

import Html exposing (..)
import App.Types.Session exposing (Session)
import App.Types.Coto exposing (Coto)
import App.Types.Graph exposing (Direction)
import App.Messages exposing (Msg(..))
import App.Views.ProfileModal
import App.Views.ConnectModal
import Components.ConfirmModal.Model
import Components.ConfirmModal.View
import Components.SigninModal
import Components.CotoModal
import Components.CotonomaModal.Model
import Components.CotonomaModal.View


type Modal
    = ConfirmModal Components.ConfirmModal.Model.Model
    | SigninModal Components.SigninModal.Model Bool
    | ProfileModal (Maybe Session) Bool
    | CotoModal Components.CotoModal.Model
    | CotonomaModal (Maybe Session) Components.CotonomaModal.Model.Model
    | ConnectModal Coto (List Coto) Direction


open : Modal -> List Modal -> List Modal
open modal modals =
    modal :: modals


view : List Modal -> List (Html Msg)
view modals =
    List.map
        (\modal ->
            case modal of
                ConfirmModal model ->
                    Html.map ConfirmModalMsg
                        (Components.ConfirmModal.View.view model)

                SigninModal model anyAnonymousCotos ->
                    Html.map SigninModalMsg
                        (Components.SigninModal.view model anyAnonymousCotos)

                ProfileModal maybeSession open ->
                    App.Views.ProfileModal.view maybeSession open

                CotoModal model ->
                    Html.map CotoModalMsg
                        (Components.CotoModal.view model)

                CotonomaModal maybeSession model ->
                    Html.map CotonomaModalMsg
                        (Components.CotonomaModal.View.view maybeSession model)

                ConnectModal coto selectedCotos direction ->
                    App.Views.ConnectModal.view direction selectedCotos coto
        )
        (List.reverse modals)
