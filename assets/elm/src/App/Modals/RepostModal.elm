module App.Modals.RepostModal exposing
    ( Model
    , initModel
    , update
    , view
    )

import App.I18n.Keys as I18nKeys
import App.Messages as AppMsg
import App.Modals.RepostModalMsg as ModalMsg exposing (Msg(..))
import App.Submodels.Context exposing (Context)
import App.Types.Coto exposing (Coto)
import Html exposing (..)
import Utils.Modal
import Utils.UpdateUtil exposing (..)


type alias Model =
    { coto : Coto
    }


initModel : Coto -> Model
initModel coto =
    { coto = coto
    }


view : Context a -> Model -> Html AppMsg.Msg
view context model =
    model
        |> modalConfig context
        |> Utils.Modal.view "repost-modal"


modalConfig : Context context -> Model -> Utils.Modal.Config AppMsg.Msg
modalConfig context model =
    { closeMessage = AppMsg.CloseModal
    , title = text (context.i18nText I18nKeys.RepostModal_Title)
    , content = div [] []
    , buttons = []
    }


update : Context context -> ModalMsg.Msg -> Model -> ( Model, Cmd AppMsg.Msg )
update context msg model =
    case msg of
        NoOp ->
            model |> withoutCmd
