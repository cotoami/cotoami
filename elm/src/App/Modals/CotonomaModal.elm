module App.Modals.CotonomaModal
    exposing
        ( Model
        , defaultModel
        , update
        , view
        )

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Util.Modal as Modal
import App.Types.Session exposing (Session, toAmishi)
import App.Types.Coto exposing (cotonomaNameMaxlength, validateCotonomaName)
import App.Types.Context exposing (Context)
import App.Messages as AppMsg exposing (Msg(CloseModal, NoOp, PostCotonoma))
import App.Modals.CotonomaModalMsg as CotonomaModalMsg exposing (Msg(..))


type alias Model =
    { name : String
    }


defaultModel : Model
defaultModel =
    { name = ""
    }


update : CotonomaModalMsg.Msg -> Session -> Context -> Model -> ( Model, Cmd CotonomaModalMsg.Msg )
update msg session context model =
    case msg of
        CotonomaModalMsg.NoOp ->
            ( model, Cmd.none )

        NameInput content ->
            ( { model | name = content }, Cmd.none )


view : Maybe Session -> Model -> Html AppMsg.Msg
view maybeSession model =
    Modal.view
        "cotonoma-modal"
        (case maybeSession of
            Nothing ->
                Nothing

            Just session ->
                Just (modalConfig session model)
        )


modalConfig : Session -> Model -> Modal.Config AppMsg.Msg
modalConfig session model =
    { closeMessage = CloseModal
    , title = "Cotonoma"
    , content =
        div []
            [ div []
                [ label [] [ text "Name" ]
                , input
                    [ type_ "text"
                    , class "u-full-width"
                    , name "name"
                    , placeholder "Name"
                    , maxlength cotonomaNameMaxlength
                    , value model.name
                    , onInput (AppMsg.CotonomaModalMsg << NameInput)
                    ]
                    []
                ]
            ]
    , buttons =
        [ button
            [ class "button button-primary"
            , disabled (not (validateCotonomaName model.name))
            , onClick PostCotonoma
            ]
            [ text "Create" ]
        ]
    }
