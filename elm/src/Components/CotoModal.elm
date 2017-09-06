module Components.CotoModal exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Util.Modal as Modal
import App.Types.Coto exposing (Coto)
import App.Markdown
import App.Messages exposing (Msg(..))
import App.Types.CotoModal exposing (..)


update : Msg -> CotoModal -> ( CotoModal, Cmd Msg )
update msg model =
    case msg of
        CloseCotoModal ->
            ( { model | open = False }, Cmd.none )

        ConfirmDeleteCoto ->
            ( model, Cmd.none )

        DeleteCoto coto ->
            ( { model | open = False }, Cmd.none )

        _ ->
            ( model, Cmd.none )


view : CotoModal -> Html Msg
view model =
    Modal.view
        "coto-modal"
        (if model.open then
            case model.coto of
                Nothing ->
                    Nothing

                Just coto ->
                    Just (modalConfig coto model)
         else
            Nothing
        )


modalConfig : Coto -> CotoModal -> Modal.Config Msg
modalConfig coto model =
    { closeMessage = CloseCotoModal
    , title =
        if coto.asCotonoma then
            "Cotonoma"
        else
            "Coto"
    , content =
        div []
            [ div [ class "coto-content" ]
                [ App.Markdown.markdown coto.content
                ]
            ]
    , buttons =
        [ if coto.asCotonoma then
            span [] []
          else
            button [ class "button", onClick ConfirmDeleteCoto ] [ text "Delete" ]
        ]
    }
