module Components.ConnectModal exposing (..)

import Html exposing (..)
import Modal


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


view : Model -> Html Msg
view model =
    Modal.view
        "profile-modal"
        (if model.open then
            Just (modalConfig model)
         else
            Nothing
        )


modalConfig : Model -> Modal.Config Msg
modalConfig model =
    { closeMessage = Close
    , title = "Connect cotos"
    , content = div []
        [ 
        ]
    , buttons = []
    }
