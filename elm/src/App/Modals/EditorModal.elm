module App.Modals.EditorModal
    exposing
        ( Model
        , initModel
        )

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Util.Modal as Modal
import App.Types.Coto exposing (Coto)
import App.Messages as AppMsg exposing (Msg(CloseModal))


type alias Model =
    { coto : Maybe Coto
    , summary : String
    , content : String
    }


initModel : Maybe Coto -> Model
initModel maybeCoto =
    { coto = maybeCoto
    , summary =
        maybeCoto
            |> Maybe.map (\coto -> Maybe.withDefault "" coto.summary)
            |> Maybe.withDefault ""
    , content =
        maybeCoto
            |> Maybe.map (\coto -> coto.content)
            |> Maybe.withDefault ""
    }


view : Model -> Html AppMsg.Msg
view model =
    modalConfig model
        |> Just
        |> Modal.view "editor-modal"


modalConfig : Model -> Modal.Config AppMsg.Msg
modalConfig model =
    { closeMessage = CloseModal
    , title = text "New Coto"
    , content =
        div [] []
    , buttons =
        [ button [ class "button", onClick CloseModal ] [ text "Post" ] ]
    }
