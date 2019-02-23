module App.Modals.ConnectionModal exposing
    ( Model
    , initModel
    , sendInit
    , update
    , view
    )

import App.Commands
import App.I18n.Keys as I18nKeys
import App.Messages as AppMsg exposing (Msg(CloseModal))
import App.Modals.ConnectionModalMsg as ModalMsg exposing (Msg(..))
import App.Submodels.Context exposing (Context)
import App.Types.Amishi exposing (Amishi)
import App.Types.Connection exposing (Connection)
import App.Types.Coto exposing (Coto)
import App.Types.Graph exposing (Graph)
import App.Views.Amishi
import App.Views.Connection
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Utils.HtmlUtil exposing (faIcon)
import Utils.Modal
import Utils.UpdateUtil exposing (..)


type alias Model =
    { connection : Connection
    , amishi : Maybe Amishi
    , startCoto : Coto
    , endCoto : Coto
    , linkingPhrase : String
    }


initModel : Context context -> Connection -> Coto -> Coto -> Model
initModel context connection startCoto endCoto =
    { connection = connection
    , amishi = Nothing
    , startCoto = startCoto
    , endCoto = endCoto
    , linkingPhrase = connection.linkingPhrase |> Maybe.withDefault ""
    }
        |> setMeAsAmishiIfSo context


setMeAsAmishiIfSo : Context context -> Model -> Model
setMeAsAmishiIfSo context model =
    { model
        | amishi =
            context.session
                |> Maybe.andThen
                    (\session ->
                        if model.connection.amishiId == session.amishi.id then
                            Just session.amishi

                        else
                            Nothing
                    )
    }


isPin : Context context -> Model -> Bool
isPin context model =
    Just model.startCoto.id == Maybe.map .cotoId context.cotonoma


view : Context context -> Model -> Html AppMsg.Msg
view context model =
    model
        |> modalConfig context
        |> Utils.Modal.view "connection-modal"


modalConfig : Context context -> Model -> Utils.Modal.Config AppMsg.Msg
modalConfig context model =
    { closeMessage = CloseModal
    , title = text (context.i18nText I18nKeys.ConnectionModal_Title)
    , content = modalContent context model
    , buttons = buttons context model
    }


modalContent : Context context -> Model -> Html AppMsg.Msg
modalContent context model =
    div [ id "connection" ]
        [ div
            [ class "amishi" ]
            [ model.amishi
                |> Maybe.map (App.Views.Amishi.inline [])
                |> Maybe.withDefault Utils.HtmlUtil.loadingHorizontalImg
            ]
        , div
            [ class "start" ]
            [ span [ class "node-title" ] [ text "From:" ]
            , App.Views.Connection.cotoDiv model.startCoto
            ]
        , App.Views.Connection.linkingPhraseInputDiv
            context
            (\_ -> AppMsg.NoOp)
            (Just model.linkingPhrase)
        , div
            [ class "end" ]
            [ span [ class "node-title" ] [ text "To:" ]
            , App.Views.Connection.cotoDiv model.endCoto
            ]
        ]


buttons : Context context -> Model -> List (Html AppMsg.Msg)
buttons context model =
    let
        onDisconnectClick =
            if isPin context model then
                AppMsg.ConfirmUnpinCoto model.endCoto.id

            else
                AppMsg.OpenConfirmModal
                    (context.i18nText I18nKeys.ConfirmDisconnect)
                    (AppMsg.DeleteConnection ( model.startCoto.id, model.endCoto.id ))
    in
    [ button
        [ class "button disconnect"
        , onClick onDisconnectClick
        ]
        [ faIcon "unlink" Nothing
        , text (context.i18nText I18nKeys.ConnectionModal_Disconnect)
        ]
    , button
        [ class "button button-primary"
        , autofocus True
        ]
        [ text (context.i18nText I18nKeys.Save) ]
    ]


update :
    Context context
    -> ModalMsg.Msg
    -> ( Model, Graph )
    -> ( ( Model, Graph ), Cmd AppMsg.Msg )
update context msg (( modal, graph ) as model) =
    case msg of
        Init ->
            model |> withoutCmd

        AmishiFetched (Ok amishi) ->
            ( { modal | amishi = Just amishi }, graph )
                |> withoutCmd

        AmishiFetched (Err error) ->
            model |> withoutCmd


sendInit : Cmd AppMsg.Msg
sendInit =
    AppMsg.ConnectionModalMsg Init
        |> App.Commands.sendMsg
