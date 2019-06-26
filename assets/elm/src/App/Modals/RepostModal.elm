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
import Html.Attributes exposing (..)
import Utils.Modal
import Utils.StringUtil
import Utils.UpdateUtil exposing (..)


type alias Model =
    { coto : Coto
    , cotonomaName : String
    , requestProcessing : Bool
    }


initModel : Coto -> Model
initModel coto =
    { coto = coto
    , cotonomaName = ""
    , requestProcessing = False
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
    , content =
        div []
            [ div []
                [ input
                    [ type_ "text"
                    , class "cotonoma-name u-full-width"
                    , placeholder "Cotonoma name"
                    ]
                    []
                ]
            ]
    , buttons =
        [ button
            [ class "button button-primary"
            , disabled
                (Utils.StringUtil.isBlank model.cotonomaName
                    || model.requestProcessing
                )
            ]
            [ if model.requestProcessing then
                text (context.i18nText I18nKeys.InviteModal_Sending ++ "...")

              else
                text (context.i18nText I18nKeys.InviteModal_SendInvite)
            ]
        ]
    }


update : Context context -> ModalMsg.Msg -> Model -> ( Model, Cmd AppMsg.Msg )
update context msg model =
    case msg of
        NoOp ->
            model |> withoutCmd
