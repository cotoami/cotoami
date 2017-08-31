module Components.CotoModal exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Util.Modal as Modal
import App.Types.Coto exposing (Coto)
import App.Markdown


type alias Model =
    { open : Bool
    , coto : Maybe Coto
    }


initModel : Model
initModel =
    { open = False
    , coto = Nothing
    }


type Msg
    = Close
    | ConfirmDelete
    | Delete Coto


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Close ->
            ( { model | open = False }, Cmd.none )

        ConfirmDelete ->
            ( model, Cmd.none )

        Delete coto ->
            ( { model | open = False }, Cmd.none )


view : Model -> Html Msg
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


modalConfig : Coto -> Model -> Modal.Config Msg
modalConfig coto model =
    { closeMessage = Close
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
            button [ class "button", onClick ConfirmDelete ] [ text "Delete" ]
        ]
    }
