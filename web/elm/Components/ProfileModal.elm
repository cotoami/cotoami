module Components.ProfileModal exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Modal
import App.Types exposing (Session)

type alias Model =
    { open : Bool
    }


initModel : Model
initModel =
    { open = False
    }


type Msg
    = Close


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Close ->
            ( { model | open = False }, Cmd.none )


view : Model -> Maybe Session -> Html Msg
view model maybeSession =
    Modal.view
        (case maybeSession of
            Nothing -> Nothing
            Just session -> 
                (if model.open then
                    Just (modalConfig model session)
                 else
                    Nothing
                )
        )


modalConfig : Model -> Session -> Modal.Config Msg
modalConfig model session =
    { closeMessage = Close
    , title = "Amishi Profile"
    , content = div []
        []
    , buttons = 
        [ button [ class "button" ] [ text "Sign out" ]
        , button [ class "button button-primary", onClick Close ] [ text "OK" ] 
        ]
    }
