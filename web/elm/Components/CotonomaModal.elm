module Components.CotonomaModal exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
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
        "coto-cotonoma"
        (if model.open then
            Just (modalConfig model)
         else
            Nothing
        )
      

modalConfig : Model -> Modal.Config Msg
modalConfig model =
    { closeMessage = Close
    , title = "Cotonoma"
    , content = div [ id "cotonoma-modal-content" ]
        [ 
        ]
    , buttons = 
        [ a 
            [ class "button button-primary"
            ] 
            [ text "Create" ]
        ]
    }
