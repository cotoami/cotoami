module Components.ConfirmModal exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
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
        "confirm-modal"
        (if model.open then
            Just (modalConfig model)
         else
            Nothing
        )
      

modalConfig : Model -> Modal.Config Msg
modalConfig model =
    { closeMessage = Close
    , title = "Confirm"
    , content = div [ id "confirm-modal-content" ] [ text "Are you sure?" ]
    , buttons = 
        [ button [ class "button", onClick Close ] [ text "Cancel" ] 
        , button [ class "button button-primary", onClick Close ] [ text "OK" ] 
        ]
    }
