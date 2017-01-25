module Components.CotoModal exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Modal
import App.Types exposing (Coto)


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
    
    
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Close ->
            ( { model | open = False }, Cmd.none )


view : Model -> Html Msg
view model =
    Modal.view
        (if model.open then
            Just (modalConfig model)
         else
            Nothing
        )
      

modalConfig : Model -> Modal.Config Msg
modalConfig model =
    { closeMessage = Close
    , title = "Coto"
    , content = div [ id "coto-modal-content" ]
        [ div [ class "coto container" ]
            [
            ]
        ]
    , buttons = 
        [ a [ class "button" ] [ text "Delete" ]
        ]
    }
